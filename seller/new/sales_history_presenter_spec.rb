require 'rails_helper'

module SellerApp
  module SalePresenters
    describe SalesHistoryPresenter do
      subject { described_class.new sales }

      let(:sales) do
        [OpenStruct.new(
          sold_at: '19/02/1905', total: '55.55', payment_method: 'moip_boleto',
          books: [
            { author: 'AuthorA', title: 'Title', publisher: 'Publisher', description: 'Desc',
              price: '1.99', shelf: 'Artes', isbn: 'ISBN', ev_code: 'ev903012784-1' },
            { author: 'AuthorB', title: 'Title', publisher: 'Publisher', description: 'Desc',
              price: '1.99', shelf: 'Artes', isbn: 'ISBN', ev_code: 'ev903012784-2' }
          ],
          status: 'envio', status_label: 'envio',
          status_class_label: 'icon-envio', buyer_id: 42, buyer_name: 'Buyer name',
          buyer_tax_document: '26361701700', delivery_address: 'address', delivery_city: 'city',
          delivery_complement: 'complement', delivery_method: 'normal',
          delivery_neighborhood: 'neighborhood', delivery_number: 'number',
          delivery_state: 'state', delivery_zip_code: '22071100', shipping_value: 10,
          shipping_tracking: 'A999999999', shipping_tracking_url: 'fa.ke'
        )]
      end

      context '.present' do
        let(:attributes) do
          {
            total: 55.55,
            price: 1.99,
            shipping_split: 5.0,
            shipping_price: 10.0,
            buyer_tax_document: '26361701700'
          }
        end

        it { expect(subject.present.size).to eq 2 }
        it { expect(subject.present.first).to have_attributes attributes }
      end

      context '.to_a' do
        context 'when there is no sales' do
          let(:sales) { [] }

          it { expect(subject.to_a).to be_empty }
        end

        context 'when there are sales' do
          let(:result) do
            [['19/02/1905', 'envio', nil, 'ev903012784-1', 'Title', 'AuthorA', 'Publisher',
              'Desc', 'Artes', 'ISBN', 'Buyer name', '26361701700', nil, 'address', nil,
              'number', 'complement', 'neighborhood', 'state', nil, 'city', '22071100',
              'normal', 'A999999999', 'fa.ke', ' 10,00', ' 5,00', ' 1,99', ' 55,55'],
             ['19/02/1905', 'envio', nil, 'ev903012784-2', 'Title', 'AuthorB', 'Publisher',
              'Desc', 'Artes', 'ISBN', 'Buyer name', '26361701700', nil, 'address', nil,
              'number', 'complement', 'neighborhood', 'state', nil, 'city', '22071100',
              'normal', 'A999999999', 'fa.ke', ' 10,00', ' 5,00', ' 1,99', ' 55,55']]
          end

          it { expect(subject.to_a).to match_array result }
        end
      end
    end
  end
end
