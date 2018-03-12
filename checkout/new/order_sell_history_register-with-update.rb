module EvMain
  class OrderSellHistoryRegister
    def initialize(order, logger = LogManager, vendas_adapter = VendasAdapter)
      @order = order
      @logger = logger.new data: { caller: self.class.name,
                                   order: @order.uuid,
                                   cart_key: @order.cart_id }
      @vendas_adapter = vendas_adapter
    end

    def perform!
      create_sell_history
      create_venda_record!
    end

    def perform_pre_vendas!
      @order.available_packages.each do |package|
        begin
          venda_record = VendasRecord.where(order_id: package.external_id).first
          venda_record.update_attributes(update_venda_attributes)
          PreVendasRecord.create! pre_vendas_attributes(venda_record, package)
          create_balcao(package)
          if should_create_vendas_parcelamento?
            VendasParcelamentoRecord.create! vendas_parcelamento_attributes
          end
        end
      end
    end

    private

    def create_sell_history
      @order.sell_history = CreateSellHistoryField.new(user_id: @order.customer.external_id,
                                                       shipping: @order.shipping,
                                                       receiver_name: @order.receiver_name).execute
      OrderRepository.new.update(@order)
    end

    def create_venda_record!
      error_data = []
      @order.available_packages.map do |package|
        begin
          @logger.info "create_venda_record to package: #{package.id}"
          venda_record = VendasRecord.create! @vendas_adapter.adapt(package)
          create_vendas_items(venda_record, package)
          save_venda_to_package(venda_record, package)
          venda_record
        rescue StandardError => e
          error_message = "Erro Retrocompatibilidade: #{e.message} - #{package.id}"
          error_data << error_message
          @logger.error(error_message + "\n#{e.backtrace.join("\n")}")
        end
      end
    rescue
      raise RetrocompatibilidadeError.new(error_data, @order.uuid) if error_data.present?
    end

    def should_create_vendas_parcelamento?
      @order.payment_credit_card? && !VendasParcelamentoRecord.exists?(cart_key: @order.cart_id)
    end

    def create_vendas_items(venda_record, package)
      Rails.logger.info 'EvMain::OrderSellHistoryRegister:create_vendas_items'
      package.available_items.each do |item|
        begin
          catalogo_record = CatalogoRecord.find_by(rec_id: item.external_id)
          VendaItemsRecord.create! venda_items_attributes(catalogo_record, item.external_id,
                                                          package, venda_record.order_id)
        rescue StandardError => e
          Rails.logger.error "Erro no create_vendas_items #{e.message} #{item.external_id}"
        end
      end
    end

    def create_balcao(package)
      package.available_items.each do |item|
        BalcaoRecord.create! balcao_record_attributes(item, package.gateway_id)
      end
    end

    def save_venda_to_package(venda_record, package)
      package_evmain_record = OrderPackageEvmainRecord.new
      package_evmain_record.external_id = venda_record.order_id
      package_record = package.send(:get_record)
      package_record.evmain = package_evmain_record
      package_record.save!
    end

    # FIXME, this method is not been used, why?
    def update_catalog_status
      rec_ids = @order.available_items.map(&:external_id)
      catalog_items = CatalogoRecord.where(rec_id: rec_ids)
      catalog_items.each do |catalog|
        catalog.ativo = CATALOGO_VENDIDO
        catalog.save!
      end
    end

    def update_venda_attributes
      {
        fpagamento: format_payment_type(@order.gateway_type),
        payment_type: @order.gateway_type,
        status: format_status(@order),
        cpf_cnpj: @order.customer.tin
      }
    end

    def format_payment_type(payment_type)
      case payment_type
      when :moip_cc then
        'moip_cc'
      when :express then
        'paypal'
      when :billet then
        'moip_boleto'
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

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def venda_items_attributes(catalogo_record, external_id, package, order_id)
      {
        order_id: order_id,
        rec_id: external_id,
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
        tipo_enriquecimento: catalogo_record.enriched?
      }
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def vendas_parcelamento_attributes
      {
        cart_key: @order.cart_id,
        installment_count:  @order.payment_installments,
        installment_value:  @order.payment_installments_value,
        tax: INSTALLMENTS_PERCENTAGE_TAX,
        total_value_cart: @order.total_paid_by_customer
      }
    end

    def balcao_record_attributes(item, gateway_id)
      {
        cart_key: @order.cart_id,
        rec_id: item.external_id,
        log: Time.zone.now,
        status: 2,
        workstation_key: nil,
        tracking_id: gateway_id
      }
    end

    def pre_vendas_attributes(venda_record, package)
      {
        order_id: venda_record.order_id,
        cart_key: @order.cart_id,
        tracking_id: @order.gateway_id,
        paykey: package.gateway_id,
        log: Time.zone.now,
        cart_version: 2
      }
    end
  end
end
