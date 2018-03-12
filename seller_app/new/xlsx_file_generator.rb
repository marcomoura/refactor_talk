module SellerApp
  module Generators
    class XlsxFileGenerator
      def self.build(sales)
        new sales.present, sales.header
      end

      delegate :path, :unlink, :read, to: :@file

      def initialize(items, header, file = Tempfile.new)
        @items = items
        @header = header
        @file = file
      end

      def name
        "vendas_#{Date.current.strftime '%d_%m_%Y'}.xlsx"
      end

      # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/BlockLength
      def generate
        XlsxWriter::Workbook.open path do |wb|
          wb.add_worksheet do |ws|
            ws.add_row @header
            @items.each.with_index(1) do |item, i|
              ws.write_string(i, 0, item.sold_at, nil)
              ws.write_string(i, 1, item.status_label, nil)
              ws.write_string(i, 2, item.order_id, nil)
              ws.write_string(i, 3, item.ev_code, nil)
              ws.write_string(i, 4, item.title, nil)
              ws.write_string(i, 5, item.author, nil)
              ws.write_string(i, 6, item.publisher, nil)
              ws.write_string(i, 7, item.description, nil)
              ws.write_string(i, 8, item.shelf, nil)
              ws.write_string(i, 9, item.isbn, nil)
              ws.write_string(i, 10, item.buyer_name, nil)
              ws.write_string(i, 11, item.buyer_tax_document, nil)
              ws.write_string(i, 12, item.delivery_name, nil)
              ws.write_string(i, 13, item.delivery_address, nil)
              ws.write_string(i, 14, item.delivery_street, nil)
              ws.write_string(i, 15, item.delivery_number, nil)
              ws.write_string(i, 16, item.delivery_complement, nil)
              ws.write_string(i, 17, item.delivery_neighborhood, nil)
              ws.write_string(i, 18, item.delivery_state, nil)
              ws.write_string(i, 19, item.delivery_uf, nil)
              ws.write_string(i, 20, item.delivery_city, nil)
              ws.write_string(i, 21, item.delivery_zip_code, nil)
              ws.write_string(i, 22, item.delivery_method, nil)
              ws.write_string(i, 23, item.shipping_tracking, nil)
              ws.write_string(i, 24, item.shipping_tracking_url, nil)

              ws.write_number(i, 25, item.shipping_price, nil)
              ws.write_number(i, 26, item.shipping_split, nil)
              ws.write_number(i, 27, item.price, nil)
              ws.write_number(i, 28, item.total, nil)
            end
          end
        end
      end
      # rubocop:enable Metrics/AbcSize,Metrics/MethodLength,Metrics/BlockLength
    end
  end
end
