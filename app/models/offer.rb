class Offer < ApplicationRecord
  MAX_CART_HOLD_TIME = 60
  has_one :order
  belongs_to :product
  enum :status, { available: 0, on_hold: 1, accepted: 2}

  def complete
    self.update(status: 2, current: false)
    self.product.increment_number_sold
  end

  def create_checkout
    self.prepare_for_checkout
    order = self.build_order(product_id: self.product_id)
    order.save
    self.update(status: "on_hold", start_time: DateTime.now)
    checkout_url = StripeCheckoutsService.new.create_session(order)
    return checkout_url
  end

  def prepare_for_checkout
    if self.hold_expired?
      self.release_hold
    end
  end

  def release_hold
    StripeCheckoutsService.new.expire_session(self.order.checkout_session)
    self.order.delete
    self.available!
  end

  def eligible_for_checkout?
    self.current==true && (self.available? || self.hold_expired?)
  end

  def hold_expired?
    self.on_hold? && self.cart_time_limit_exceeded?
  end

  def cart_time_limit_exceeded?
    self.start_time.since(MAX_CART_HOLD_TIME)<DateTime.now
  end




end
