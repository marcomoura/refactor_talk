module SellerApp
  module SalePresenters
    class SalesPresenter
      def self.present(data, seller_id)
        new(data, seller_id).sales
      end

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
        @_sales ||= @data.map { |sale| OpenStruct.new(build_sale(sale)) }
      end

      private

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

      def order_status
        I18n.t('seller_app.sale_presenters.order_status')
      end

      def status_to_label(status, delivery_method)
        if status.nil?
          order_status[:default]
        elsif status.to_i == 1 && delivery_method == 'local'
          # Media provisoria enquanto o status 6 (waiting_for_withdrawn)
          # nao e retornado pela query do Solr
          order_status[6]
        else
          order_status[status.to_i]
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
            description: book_params[8],
            ev_code: sale_builder.generate_ev_code(book_params[9]),
            price: book_params[10],
            shelf: book_params[11],
            isbn: book_params[12]
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
