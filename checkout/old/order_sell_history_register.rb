module EvMain
  class OrderSellHistoryRegister
    def perform!
      create_sell_history
      create_venda_record!
    end

    private

    def create_venda_record!
      error_data = []
      @order.available_packages.select { |package| package.external_id.nil? }.map do |package|
        begin
          @logger.info "create_venda_record to package: #{package.id}"
          venda_record = create_venda_record(package)
          create_vendas_items(venda_record, package)
          create_venda_detalhes(venda_record)
          create_pre_vendas(venda_record, package)

          create_taxes(venda_record, package)
          save_venda_to_package(venda_record, package)

          save_venda_to_package(venda_record, package)
          venda_record
        rescue StandardError => e
          error_data << "Erro Retrocompatibilidade: #{e.message} - #{package.id}"
          @logger.error("Erro Retrocompatibilidade: #{e.message} - #{package.id}")
        end
      end
    rescue
      raise RetrocompatibilidadeError.new(error_data, @order.uuid) if error_data.present?
    end

    def create_venda_record(package)
      VendasRecord
        .create!(cart_key: @order.cart_id,
                 comprador: @order.customer.external_id,
                 vendedor: package.seller.external_id,
                 subtotal: package.subtotal,
                 frete: package.shipping_price_with_picking,
                 frete_real: package.shipping_price,
                 total: package.total_price,
                 fenvio: package.shipping_delivery_type,
                 fpagamento: format_payment_type(@order.gateway_type, package),
                 log: Time.zone.now,
                 status: format_status(@order),
                 log2: nil,
                 controle_comercial: nil,
                 comentario_pos: nil,
                 qual_atendimento: 0,
                 replica: nil,
                 causa_cancelamento: nil,
                 cod_rastreamento: nil,
                 enviado_em: nil,
                 n_reat: 0,
                 gift_wrap: 0,
                 gift_send: gift_send?(@order),
                 cancelado_em: nil,
                 nlivros: package.available_items.size,
                 log_replica_vendedor: nil,
                 montante_ev: package.ev_amount,
                 montante_gateway: package.gateway_profit,
                 is_guest: @order.as_guest?)
    end

    def format_payment_type(payment_type, package)
      case payment_type
        when :moip_cc then
          "moip_cc"
        when :express then
          "paypal"
        when :billet then
          "moip_boleto"
      end
    end


    def format_status(order)
      if order.gateway_id.blank?
        START_PROCESSING_AND_AVOID_QUIMERA
      elsif order.gateway_type == :express
        PROCESSING_BUT_AVOID_QUIMERA
      else
        PROCESSING
      end
    end

    def create_vendas_items(venda_record, package)
      Rails.logger.info 'EvMain::OrderSellHistoryRegister:create_vendas_items'
      package.available_items.each do |item|
        begin
          catalogo_record = find_by_rec_id(item.external_id)
          persist_venda_items_record(catalogo_record, item, package, venda_record)
        rescue StandardError => e
          Rails.logger.error "Erro no create_vendas_items #{e.message} #{item.external_id}"
        end
      end
    end

    def find_by_rec_id(rec_id)
      CatalogoRecord.find_by(rec_id: rec_id)
    end

    def persist_venda_items_record(catalogo_record, item, package, venda_record)
      VendaItemsRecord
        .new(order_id: venda_record.order_id,
             rec_id: item.external_id,
             autor: catalogo_record.autor,
             titulo: catalogo_record.titulo,
             editora: catalogo_record.editora,
             ano: catalogo_record.ano,
             descr: catalogo_record.descr,
             capa: catalogo_record.capa,
             idioma: catalogo_record.idioma,
             peso: catalogo_record.peso,
             peso_est: catalogo_record.peso_est,
             user_id: package.seller.external_id,
             preco: catalogo_record.preco,
             estante: catalogo_record.estante,
             estante_id: catalogo_record.estante_id,
             montante_ev: package.ev_amount,
             montante_gateway: package.gateway_profit,
             isbn: catalogo_record.isbn,
             edition: catalogo_record.edition,
             barcode: catalogo_record.barcode,
             location_in_store: catalogo_record.location_in_store,
             category: catalogo_record.category,
             book_type: catalogo_record.tipo,
             dna_crc: catalogo_record.dna_crc,
             uuid: catalogo_record.uuid,
             tipo_enriquecimento: catalogo_record.enriched?)
        .save!
    end

    def create_venda_detalhes(venda_record)
      VendasDetalhesRecord.new({
        order_id: venda_record.order_id,
        dest_cep: @order.shipping.address.zipcode,
        dest_end: format_street(@order.shipping.address),
        dest_bairro: @order.shipping.address.neighborhood,
        dest_cidade: @order.shipping.address.city,
        dest_estado: @order.shipping.address.state,
        dest_nome: set_receiver_name,
        mensagem: nil,
        log: Time.zone.now,
        envio_dados_bancarios: nil,
        paypal_desconto_frete: 2.00
      }).save!
    end

    def set_receiver_name
      order_receiver_name = @order.shipping.receiver_name
      order_receiver_name.present? ? order_receiver_name : @order.customer.name
    end

    def format_street(address)
      street = "#{address.street}, #{address.number}"
      if ! address.complement.blank?
        street = "#{street} / #{address.complement}"
      end
      street
    end

    def create_vendas_parcelamento
      VendasParcelamentoRecord
        .new(cart_key: @order.cart_id,
             installment_count:  @order.payment_installments,
             installment_value:  @order.payment_installments_value,
             tax: INSTALLMENTS_PERCENTAGE_TAX,
             total_value_cart: @order.total_paid_by_customer)
        .save!
    end

    def create_balcao(package)
      package.available_items.each do |item|
        create_balcao_record(item, package)
      end
    end

    def create_balcao_record(item, package)
      BalcaoRecord
        .new(cart_key: @order.cart_id,
             rec_id: item.external_id,
             log: Time.zone.now,
             status: 2,
             workstation_key: nil,
             tracking_id: package.gateway_id)
        .save!
    end

    def create_pre_vendas(venda_record, package)
      PreVendasRecord
        .new(order_id: venda_record.order_id,
             cart_key: @order.cart_id,
             tracking_id: @order.gateway_id,
             paykey: package.gateway_id,
             log: Time.zone.now,
             cart_version: 2)
        .save!
    end

    def save_venda_to_package(venda_record, package)
      package_evmain_record = OrderPackageEvmainRecord.new
      package_evmain_record.external_id = venda_record.order_id
      package_record = package.send(:get_record)
      package_record.evmain = package_evmain_record
      package_record.save!
    end

    def gift_send?(order)
      is_ev_main = order.customer.is_evmain_address?(order.shipping.address)
      if is_ev_main
        0
      else
        1
      end
    end

    def create_vendas_taxas(venda_record, package)
      VendasTaxasRecord
        .create!(
          cartao_salvo: package.payment_transaction_saved_card,
          juros: package.interest,
          ev_spread: package.ev_spread_amount,
          ev_recebido: package.ev_received,
          ev_total_recebido: package.ev_total_received,
          ev_taxa: package.commission_ev_percentage,
          gateway_montante_nominal_total: package.gateway_nominal_total_profit,
          gateway_tarifa_nominal: package.gateway_nominal_fee_tax,
          gateway_taxa_nominal: package.gateway_nominal_tax,
          gateway_montante_efetivo: package.gateway_effective_profit,
          gateway_tarifa_efetiva: package.gateway_effective_fee_tax,
          gateway_taxa_efetiva: package.gateway_effective_tax,
          seller_amount: package.seller_amount,
          vendedor_recebido_liquido: package.seller_net_amount
      )
    end
  end
end
