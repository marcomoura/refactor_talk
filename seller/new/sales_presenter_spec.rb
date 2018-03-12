require 'rails_helper'

module SellerApp
  module SalePresenters
    describe SalesPresenter do
      context '.sales' do
        subject { described_class.new(sale, '666').sales.first }

        let(:sale) do
          [
            { status: status, sold_at: '19/02/1905', total: 55.55, buyer_id: 42,
              shipping_tracking_url: 'www.fa.ke', shipping_tracking: 'A999999999',
              shipping_value: 10, payment_method: 'moip_boleto',
              buyer_name: 'Buyer name', buyer_tax_document: '26361701700',
              delivery_city: 'city',
              delivery_state: 'state',
              delivery_zip_code: '22071100',
              delivery_address: 'address',
              delivery_number: 'number',
              delivery_complement: 'complement',
              delivery_neighborhood: 'neighborhood',
              delivery_method: 'normal',

              items: 'AuthorA#-#Title#-#Publisher#-#1#-#Pt#-#location_in_store#-' \
                     '#category#-#1999#-#Desc#-#903012784#-#1.99#-#Artes#-#ISBN' \
                     '----line----' \
                     'AuthorB#-#Title#-#Publisher#-#1#-#Pt#-#location_in_store#-' \
                     '#category#-#1999#-#Desc#-#903012784#-#1.99#-#Artes#-#ISBN' }
          ]
        end
        let(:result) do
          {
            sold_at: '19/02/1905', total: 55.55, payment_method: 'moip_boleto',
            books: [
              { author: 'AuthorA', title: 'Title', publisher: 'Publisher', description: 'Desc',
                price: '1.99', shelf: 'Artes', isbn: 'ISBN', ev_code: 'ev903012784-0' },
              { author: 'AuthorB', title: 'Title', publisher: 'Publisher', description: 'Desc',
                price: '1.99', shelf: 'Artes', isbn: 'ISBN', ev_code: 'ev903012784-0' }
            ],
            status: status_label,
            status_label: I18n.t("activemodel.attributes.sale.status.#{status_label}"),
            status_class_label: "icon-#{status_class_label}",
            buyer_id: 42,
            buyer_name: 'Buyer name',
            buyer_tax_document: '26361701700',
            delivery_address: 'address',
            delivery_city: 'city',
            delivery_complement: 'complement',
            delivery_method: 'normal',
            delivery_neighborhood: 'neighborhood',
            delivery_number: 'number',
            delivery_state: 'state',
            delivery_zip_code: '22071100',
            shipping_value: 10, shipping_tracking: 'A999999999', shipping_tracking_url: 'www.fa.ke'
          }
        end

        context 'when status is nil' do
          let(:status) { nil }
          let(:status_label) { 'nil_status' }
          let(:status_class_label) { 'envio' }

          it { expect(subject).to have_attributes result }
        end

        context 'when status is -2' do
          let(:status) { -2 }
          let(:status_label) { 'expired' }
          let(:status_class_label) { 'cancelamento' }

          it { expect(subject).to have_attributes result }
        end

        context 'when status is 0' do
          let(:status) { 0 }
          let(:status_label) { 'canceled' }
          let(:status_class_label) { 'cancelamento' }

          it { expect(subject).to have_attributes result }
        end
      end
    end
  end
end
