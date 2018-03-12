module SellerApp
  module Generators
    class CsvGenerator
      def self.generate(sales)
        new(sales.present, sales.header).generate
      end

      def self.build_sales_pending(sales)
        header = I18n.t 'seller_app.csv_generator.header.sales_pending'
        presenter = sales.collect { |s| [s[:order_id], s[:buyer_name], s[:delivery_zip_code], ''] }
        new presenter, header
      end

      def initialize(items, header)
        @items = items
        @header = header
      end

      def generate
        CSV.generate headers: true, col_sep: ',' do |csv|
          @items
            .unshift(@header)
            .each { |row| csv << row }
        end
      end
    end
  end
end
