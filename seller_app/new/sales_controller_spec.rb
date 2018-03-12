require 'rails_helper'

describe SellerApp::SalesController do
  before do
    allow_any_instance_of(SellerApp::GetMenuItems).to receive(:execute)
    set_current_user('John')
  end

  #other actions contexts
  # ...

  context 'export' do
    let(:csv_string) do
      "Fake,CSV\nfirst,row,\nanother,row\n"
    end

    before do
      allow_any_instance_of(SellerApp::GetMenuItems)
        .to receive(:execute)
      allow_any_instance_of(SellerApp::SearchOrdersHistory)
        .to receive(:execute)
        .and_return(response: { docs: [] })
      allow(SellerApp::SalePresenters::SalesHistoryPresenter)
        .to receive(:build)
      allow(SellerApp::Generators::CsvGenerator)
        .to receive(:generate)
        .and_return(csv_string)
      allow(SellerApp::Generators::XlsxFileGenerator)
        .to receive(:build)
        .and_return(double.as_null_object)

      get :export, format: format
    end

    context 'when the format is a xlsx' do
      let(:format) { 'xlsx' }
      let(:content_type) do
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      end

      it { is_expected.to respond_with :ok }
      it { expect(response.content_type).to eq content_type }
    end
  end
end
