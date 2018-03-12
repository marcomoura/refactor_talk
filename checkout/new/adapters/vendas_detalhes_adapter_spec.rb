require 'rails_helper'

describe VendasDetalhesAdapter do
  describe '.adapt' do
    subject { described_class.adapt data }

    before do
      allow(Time.zone).to receive(:now).and_return('2018-01-31 13:35:00')
    end
    let(:address) do
      OpenStruct.new(
        zipcode: '22241020',
        neighborhood: 'Laranjeiras',
        city: 'Rio de Janeiro',
        state: 'RJ',
        street: 'Rua Alice',
        number: '113',
        complement: '',
        mensagem: '',
        log: '2018-18-31 13:00:00',
        envio_dados_bancarios: '',
        paypal_desconto_frete: 2.00
      )
    end

    let(:data) do
      OpenStruct.new(
        id: 1,
        shipping: OpenStruct.new(
          receiver_name: 'Alice',
          address: address
        )
      )
    end

    let(:result) do
      {
        order_id: 1,
        dest_cep: '22241020',
        dest_end: 'Rua Alice, 113',
        dest_bairro: 'Laranjeiras',
        dest_cidade: 'Rio de Janeiro',
        dest_estado: 'RJ',
        dest_nome: 'Alice',
        dest_logradouro: 'Rua Alice',
        dest_numero: '113',
        dest_complemento: '',
        mensagem: nil,
        log: Time.zone.now,
        envio_dados_bancarios: nil,
        paypal_desconto_frete: 2.00
      }
    end

    it { is_expected.to eq result }
  end
end
