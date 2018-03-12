class VendasAdapter
  class << self
    def adapt(package)
      new(package)
        .adapt
        .merge(taxas_attributes(package))
        .merge(detalhes_attributes(package.order))
    end

    private

    def taxas_attributes(package)
      { taxas_attributes: VendasTaxasAdapter.adapt(package) }
    end

    def detalhes_attributes(order)
      { detalhes_attributes: VendasDetalhesAdapter.adapt(order) }
    end
  end

  def initialize(package)
    @package = package
  end

  # rubocop:disable Metrics/AbcSize
  def adapt
    {
      cart_key: @package.order.cart_id,
      comprador: @package.order.customer.external_id,
      is_guest: @package.order.as_guest?,
      vendedor: @package.seller.external_id,
      subtotal: @package.subtotal,
      frete: @package.shipping_price_with_picking,
      frete_real: @package.shipping_price,
      total: @package.total_price,
      fenvio: @package.shipping_delivery_type,
      nlivros: @package.available_items.size,
      montante_ev: @package.ev_amount,
      montante_gateway: @package.gateway_profit,
      log: Time.zone.now,
      fpagamento: payment_type,
      status: format_status,
      gift_send: gift_send?,
      comentario_pos: nil,
      replica: nil
    }
  end
  # rubocop:enable Metrics/AbcSize

  private

  def payment_type
    case @package.order.gateway_type
    when :moip_cc then
      'moip_cc'
    when :express then
      'paypal'
    when :billet then
      'moip_boleto'
    end
  end

  def format_status
    if @package.order.gateway_id.blank?
      START_PROCESSING_AND_AVOID_QUIMERA
    elsif @package.order.gateway_type == :express
      PROCESSING_BUT_AVOID_QUIMERA
    else
      PROCESSING
    end
  end

  def gift_send?
    @package.order.customer.is_evmain_address?(@package.order.shipping.address) ? 0 : 1
  end
end
