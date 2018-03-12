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

    private

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

    def save_venda_to_package(venda_record, package)
      package_evmain_record = OrderPackageEvmainRecord.new
      package_evmain_record.external_id = venda_record.order_id
      package_record = package.send(:get_record)
      package_record.evmain = package_evmain_record
      package_record.save!
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
  end
end
