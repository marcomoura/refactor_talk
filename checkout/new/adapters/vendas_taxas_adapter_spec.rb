require 'rails_helper'

describe VendasTaxasAdapter do
  describe '.adapt' do
    subject { described_class.adapt data }

    let(:data) do
      double 'fake_package',
             order_id: 1,
             payment_transaction_saved_card: true,
             ev_spread_amount: 2,
             ev_received: 3,
             ev_total_received: 4,
             commission_ev_percentage: 5,
             gateway_nominal_total_profit: 6,
             gateway_effective_profit: 7,
             gateway_effective_fee_tax: 8,
             gateway_nominal_tax: 9,
             gateway_effective_tax: 10,
             gateway_nominal_fee_tax: 11,
             interest: 12,
             seller_amount: 13,
             seller_net_amount: 14
    end
    let(:result) do
      {
        cartao_salvo: true,
        ev_spread: 2,
        ev_recebido: 3,
        ev_total_recebido: 4,
        ev_taxa: 5,
        gateway_montante_nominal_total: 6,
        gateway_montante_efetivo: 7,
        gateway_tarifa_efetiva: 8,
        gateway_taxa_nominal: 9,
        gateway_taxa_efetiva: 10,
        gateway_tarifa_nominal: 11,
        juros: 12,
        seller_amount: 13,
        vendedor_recebido_liquido: 14
      }
    end

    it { is_expected.to eq result }
  end
end
