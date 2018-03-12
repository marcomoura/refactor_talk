require 'rails_helper'

module EvMain
  describe OrderSellHistoryRegister do
    subject { described_class.new Order.new(order) }

    let(:order) { create(:order) }

    describe '#perform!' do
      describe 'register the order in evmain' do
        describe 'when is successfull' do
          it { expect(subject.perform!).to include_kind_of EvMain::VendasRecord }
          it { expect(subject.perform!.vendas_taxas).to  }

        end

        describe 'when it fails' do
          before do
            allow(VendasRecord)
              .to receive(:create!).and_raise(StandardError)
            create :ev_main_vendas, cart_key: order.cart_id, comprador: order.customer.external_id
          end

          it 'returns an empty array' do
            expect(subject.perform!).to match_array([nil])
          end
        end
      end
    end
  end
end
