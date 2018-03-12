module SellerApp
  module SalePresenters
    class SalesHistoryPresenter
      def self.build(result, seller_id)
        new SellerApp::SalePresenters::SalesPresenter.present(result, seller_id)
      end

      attr_reader :header

      def initialize(items, helpers = ActionController::Base.helpers)
        @items = items
        @helpers = helpers
        @header = I18n.t 'seller_app.csv_generator.header.sale_history'
      end

      def present
        items do |sale, book, shipping_split|
          values = flatten(sale, book)
                   .collect(&:to_s)
                   .concat([sale[:shipping_value].to_f, shipping_split.to_f,
                            book[:price].to_f, sale[:total].to_f])
          OpenStruct.new keys.zip(values).to_h
        end
      end

      def to_a
        items do |sale, book, shipping_split|
          flatten(sale, book)
            .concat [number_to_currency(sale[:shipping_value]),
                     number_to_currency(shipping_split),
                     number_to_currency(book[:price]),
                     number_to_currency(sale[:total])]
        end
      end

      private

      def items
        @items.each_with_object [] do |sale, data|
          shipping_split = split_shipping_by_item(sale[:shipping_value], sale.books.size)

          sale.books.each do |book|
            data << yield(sale, book, shipping_split)
          end
        end
      end

      def keys
        %i[sold_at status_label order_id ev_code title author publisher description shelf isbn
           buyer_name buyer_tax_document delivery_name delivery_address delivery_street
           delivery_number delivery_complement delivery_neighborhood delivery_state
           delivery_uf delivery_city delivery_zip_code delivery_method shipping_tracking
           shipping_tracking_url shipping_price shipping_split price total]
      end

      # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      def flatten(sale, book)
        [
          sale[:sold_at],
          sale[:status_label],
          sale[:order_id],
          book[:ev_code],
          book[:title],
          book[:author],
          book[:publisher],
          book[:description],
          book[:shelf],
          book[:isbn],
          sale[:buyer_name],
          sale[:buyer_tax_document],
          sale[:delivery_name],
          sale[:delivery_address],
          sale[:delivery_street],
          sale[:delivery_number],
          sale[:delivery_complement],
          sale[:delivery_neighborhood],
          sale[:delivery_state],
          sale[:delivery_uf],
          sale[:delivery_city],
          sale[:delivery_zip_code],
          sale[:delivery_method],
          sale[:shipping_tracking],
          sale[:shipping_tracking_url]
        ]
      end
      # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

      def split_shipping_by_item(total, items)
        return 0 if items.zero?
        total.to_f / items
      end

      def number_to_currency(value)
        @helpers.number_to_currency value, unit: ''
      end
    end
  end
end
