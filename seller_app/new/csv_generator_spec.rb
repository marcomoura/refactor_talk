require 'rails_helper'

module SellerApp
  module Generators
    describe CsvGenerator do
      context '.generate' do
        subject { described_class.new rows, header }

        let(:header) { ['Test', 'Fake', 'Hea der'] }
        let(:header_result) { "Test,Fake,Hea der\n" }

        context 'when there is no sales' do
          let(:rows) { [] }

          it { expect(subject.generate).to eq header_result }
        end

        context 'when there are sales' do
          let(:result) { header_result + "1,1,1\n" + "2,2,2\n" }
          let(:rows) { [[1, 1, 1], [2, 2, 2]] }

          it { expect(subject.generate).to eq result }
        end
      end
    end
  end
end
