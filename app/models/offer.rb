class Offer < ApplicationRecord
  MAX_CART_HOLD_TIME = 60
  has_one :order
  belongs_to :product
  enum :status, {available: 0, on_hold: 1, accepted: 2}

  def complete
    update(status: 2, current: false)
    product.increment_number_sold
  end

  def create_checkout
    prepare_for_checkout
    order = create_order!(product_id: product_id)
    update!(status: "on_hold", start_time: DateTime.now)
    StripeCheckoutsService.create_session(order)
  end

  def prepare_for_checkout
    if hold_expired?
      release_hold
    end
  end

  def release_hold
    StripeCheckoutsService.expire_session(order.checkout_session)
    order.delete
    available!
  end

  def eligible_for_checkout?
    current == true && (available? || hold_expired?)
  end

  def hold_expired?
    on_hold? && cart_time_limit_exceeded?
  end

  def cart_time_limit_exceeded?
    start_time.since(MAX_CART_HOLD_TIME) < DateTime.now
  end
end
