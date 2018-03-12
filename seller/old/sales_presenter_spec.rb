require 'rails_helper'

module SellerApp
  module SalePresenters
    describe SalesPresenter do
      let(:sale) do
        [
          {
            id: 666,
            status: 'to be changed',
            sold_at: '19/02/1905',
            items: []
          }
        ]
      end
      let(:string_to_translate) { 'activemodel.attributes.sale.status' }

      it 'should return correct response value for nil' do
        sale[0][:status] = nil
        sale_presented = SalesPresenter.new(sale, '2124720').sales[0]
        expect(sale_presented[:status]).to eq 'nil_status'
        expect(sale_presented[:status_label]).to eq I18n.t("#{string_to_translate}.nil_status")
      end

      it 'should return expired response value for -2' do
        sale[0][:status] = -2
        sale_presented = SalesPresenter.new(sale, '2124720').sales[0]
        expect(sale_presented[:status]).to eq 'expired'
        expect(sale_presented[:status_label]).to eq I18n.t("#{string_to_translate}.expired")
      end

      it 'should return canceled response value for 0' do
        sale[0][:status] = 0
        sale_presented = SalesPresenter.new(sale, '2124720').sales[0]
        expect(sale_presented[:status]).to eq 'canceled'
        expect(sale_presented[:status_label]).to eq I18n.t("#{string_to_translate}.canceled")
      end
    end
  end
end
