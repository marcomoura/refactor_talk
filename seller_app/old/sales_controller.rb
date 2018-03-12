module SellerApp
  class SalesController < ApplicationController
    MAX_ROWS_FOR_ORDER_HISTORY = 5000

    # Serve duas ações com conteúdos diferentes
    # BAIXAR HISTÓRICO
    # planilha com os pedidos pendentes de ação (no adicionar rastreio em lote)
    def export
      sales = build_export # sales[:sales] <- CONTEUDO DO ARQUIVO CSV
      actual_time = Time.current.strftime('%d/%m/%Y')
      send_data(sales[:sales],
                type: Mime::CSV,
                disposition:
                "attachment; filename=#{sales[:csv_prefix]}_#{actual_time}.csv")
    end

    private

    def build_export
      export_sales_params = search_sales_params
      export_sales_params.delete('pagina')
      export_sales_params[:rows_per_page] = MAX_ROWS_FOR_ORDER_HISTORY

      if params[:is_tc_list].present? # planilha com os pedidos pendentes de ação
        export_sales_params = export_sales_params.merge(status: %w(standby delayed))
      end
      make_request(export_sales_params, params[:is_tc_list].present?)
    end

    def search_sales_params
      @search_sales_params ||= params.permit(:seller_id, :pagina, :periodo, :termo,
                                             :status, :forma_pagamento, :orders_ids)
    end

    def make_request(export_params, is_tracking_code)
      result = search_history(sales_params: export_params) # <- SEARCH_HISTORY BUSCA PEDIDOS NO ISTAMBUL
      presenter = SellerApp::SalePresenters::SalesPresenter.new( # <- ADD OS NOVOS CAMPOS NO PRESENTER
        result[:response][:docs], seller_id
      )

      if is_tracking_code
        sales = presenter.build_tc_csv
        csv_prefix = 'tc_vendas'
      else
        sales = presenter.as_csv
        csv_prefix = 'vendas'
      end
      { sales: sales, csv_prefix: csv_prefix }
    end

    def search_history(sort: nil, status: nil, sales_params: {})
      sales_params.merge!(status: status) if status.present?
      sales_params.merge!(sort: sort) if sort.present?
      SellerApp::SearchOrdersHistory.new(seller_id, sales_params).execute
    end

  end
end
