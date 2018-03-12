module SellerApp
  module SalePresenters
    class SalesPresenter
      DEFAULT_VALUE = 'nil_status'.freeze
      ORDER_STATUS = {
        -2 => 'expired',
        -1 => 'processing',
        -3 => 'processing',
        0 => 'canceled',
        1 => 'standby',
        2 => 'sent',
        3 => 'received',
        4 => 'delayed',
        5 => 'withdrawn',
        6 => 'waiting_for_withdrawn'
      }.freeze

      def initialize(data, seller_id)
        @data = data
        @seller_id = seller_id
      end

      def seller_id
        @seller_id
      end

      def tracking_code_csv_model_url
        ENV['TRACKING_CODE_MASS_INSERTION_URL']
      end

      def sales
        @sales ||= build_sales
      end

      def as_csv # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        CSV.generate do |csv|
          csv << %w(Data Status Pedido CódigoEv Título Autor Editora Estante Comprador Estado
                    Cidade Envio ValorFrete(R$) PreçoLivro(R$) ValorTotal(R$))
          sales.each do |sale|
            sale.books.each do |book|
              csv << [
                sale[:sold_at],
                sale[:status_label],
                sale[:order_id],
                book[:ev_code],
                book[:title],
                book[:author],
                book[:publisher],
                book[:shelf],
                sale[:buyer_name],
                sale[:delivery_state],
                sale[:delivery_city],
                sale[:delivery_method],
                format_currency_values(sale[:shipping_value]),
                format_currency_values(book[:price]),
                format_currency_values(sale[:total])
              ]
            end
          end
        end
      end

      def build_tc_csv
        CSV.generate do |tc_csv|
          tc_csv << ['Pedido', 'Nome do Destinatário', 'CEP', 'Código de Rastreamento']
          @data.each do |sale|
            tc_csv << [sale[:order_id], sale[:buyer_name], sale[:delivery_zip_code], '']
          end
        end
      end

      private

      def format_currency_values(value)
        ActionController::Base.helpers.number_to_currency(value, unit: '')
      end

      def build_sales
        @data.map { |sale| OpenStruct.new(build_sale(sale)) }
      end

      def build_sale(sale)
        items = sale.delete(:items)
        sale[:books] = parse_book_params(items)
        status = status_to_label(sale[:status], sale[:delivery_method])
        sale[:status] = status
        sale[:status_label] = I18n.t("activemodel.attributes.sale.status.#{status}")
        sale[:status_class_label] = status_class_label(status)
        sale[:sold_at] = sale[:sold_at].to_time.strftime('%d/%m/%Y')

        sale
      end

      def status_class_label(status)
        case status
          when 'expired'
            'icon-cancelamento'
          when 'canceled'
            'icon-cancelamento'
          else
            'icon-envio'
        end
      end

      def status_to_label(status, delivery_method)
        if status.nil?
          DEFAULT_VALUE
        elsif status.to_i == 1 && delivery_method == 'local'
          # Media provisoria enquanto o status 6 nao e retornado pela query do Solr
          ORDER_STATUS[6]
        else
          ORDER_STATUS[status.to_i]
        end
      end

      def parse_book_params(items) # rubocop:disable Metrics/MethodLength
        sale_builder = SaleBuilder.new('')
        books = items.split('----line----')
        books.map do |book|
          book_params = book.split('#-#')
          {
            author: book_params[0],
            title: book_params[1],
            publisher: book_params[2],
            price: book_params[10],
            shelf: book_params[11],
            ev_code: sale_builder.generate_ev_code(book_params[9])
          }
        end
      end

      def format_authors_and_title(sale)
        values = []
        sale[:books].each do |book|
          values << "#{book[:title]} (#{book[:author]})"
        end
        values.join(',')
      end
    end
  end
end
