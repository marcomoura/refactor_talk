class VendasDetalhesAdapter
  def self.adapt(data)
    new(data).adapt
  end

  def initialize(data)
    @data = data
  end

  def adapt
    {
      order_id: @data.id,
      dest_cep: address.zipcode,
      dest_end: format_street,
      dest_bairro: address.neighborhood,
      dest_cidade: address.city,
      dest_estado: address.state,
      dest_nome: set_receiver_name,
      dest_logradouro: address.street.truncate(100),
      dest_numero: address.number,
      dest_complemento: address.complement,
      mensagem: nil,
      log: Time.zone.now,
      envio_dados_bancarios: nil,
      paypal_desconto_frete: 2.00
    }
  end

  private

  def set_receiver_name
    order_receiver_name = @data.shipping.receiver_name
    order_receiver_name.present? ? order_receiver_name : @data.customer.name
  end

  def format_street
    street = "#{address.street}, #{address.number}"
    return "#{street} / #{address.complement}" if address.complement.present?
    street
  end

  def address
    @data.shipping.address
  end
end
