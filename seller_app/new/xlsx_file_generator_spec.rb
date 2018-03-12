require 'rails_helper'

module SellerApp
  module Generators
    describe XlsxFileGenerator do
      subject { described_class.new nil, nil }

      it { is_expected.to respond_to :path, :unlink, :read, :generate }

      context '.name' do
        before { Timecop.travel Date.new(2018, 1, 1).in_time_zone }
        after { Timecop.return }

        it { expect(subject.name).to eq 'vendas_01_01_2018.xlsx' }
      end
    end
  end
end
