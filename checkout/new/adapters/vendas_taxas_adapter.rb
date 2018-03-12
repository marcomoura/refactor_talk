class VendasTaxasAdapter
  def self.adapt(data)
    new(data).adapt
  end

  def initialize(data)
    @data = data
  end

  def adapt
    {
      cartao_salvo: @data.payment_transaction_saved_card,
      juros: @data.interest,
      ev_spread: @data.ev_spread_amount,
      ev_recebido: @data.ev_received,
      ev_total_recebido: @data.ev_total_received,
      ev_taxa: @data.commission_ev_percentage,
      gateway_montante_nominal_total: @data.gateway_nominal_total_profit,
      gateway_tarifa_nominal: @data.gateway_nominal_fee_tax,
      gateway_taxa_nominal: @data.gateway_nominal_tax,
      gateway_montante_efetivo: @data.gateway_effective_profit,
      gateway_tarifa_efetiva: @data.gateway_effective_fee_tax,
      gateway_taxa_efetiva: @data.gateway_effective_tax,
      seller_amount: @data.seller_amount,
      vendedor_recebido_liquido: @data.seller_net_amount
    }
  end
end
