module SellerApp
  class SalesController < ApplicationController
    skip_before_action :set_menu, only: %i[export export_pending_sales]

    def export_pending_sales
      result = search_history export_params.merge(status: %w[standby delayed])
      presenter = SellerApp::SalePresenters::SalesPresenter.new result[:docs], seller_id
      data = SellerApp::Generators::CsvGenerator.build_sales_pending(presenter.sales).generate
      file_name = "tc_vendas_#{Time.current.strftime('%d/%m/%Y')}.csv"

      send_attachment data, file_name, Mime::Type.lookup_by_extension('csv')
    end

    def export
      history = search_history(export_params)[:docs]
      presenter = SellerApp::SalePresenters::SalesHistoryPresenter.build history, seller_id
      cookies['fileDownload'] = 'true'

      respond_to do |format|
        format.xlsx do
          file = SellerApp::Generators::XlsxFileGenerator.build presenter
          file.generate
          send_attachment file.read, file.name, Mime::Type.lookup_by_extension(:xlsx)
          file.unlink
        end
      end
    end

    private

    def search_history(sales_params)
      Rails.logger.info("Buscando o historico de pedidos com os parametros: #{sales_params}")
      SellerApp::SearchOrdersHistory.new(seller_id, sales_params).execute[:response]
    end

    def send_attachment(data, filename, content_type)
      send_data data,
                filename: filename,
                type: content_type,
                disposition: "attachment; filename=#{filename}"
    end

    def export_params
      search_sales_params
        .except('pagina')
        .merge(rows_per_page: Rails.configuration.istambul['rows_per_page'])
    end

    def search_sales_params
      @search_sales_params ||= params.permit(:seller_id,
                                             :pagina,
                                             :periodo,
                                             :termo,
                                             :status,
                                             :forma_pagamento,
                                             :orders_ids)
    end
  end
end
