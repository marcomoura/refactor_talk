module EvMain
  class VendasRecord < EvSuper
    self.table_name = 'vendas'
    self.primary_key = 'order_id'

    has_one :taxas, class_name: EvMain::VendasTaxasRecord, inverse_of: :vendas,
                    foreign_key: :order_id, primary_key: :order_id
    has_one :detalhes, class_name: EvMain::VendasDetalhesRecord, inverse_of: :vendas,
                       foreign_key: :order_id, primary_key: :order_id

    accepts_nested_attributes_for :taxas, :detalhes
  end
end
