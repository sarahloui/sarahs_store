require "rails_helper"

describe "Offer", type: :model do
  def setup_store
    product1 = Product.create!(name: "Apron", description: "Red apron", price: 1234, number_sold: 0)
    product2 = Product.create!(name: "Blouse", description: "Silk blouse", price: 5678, number_sold: 0)
    available_offer = product1.offers.create!(status: "available", current: "true")
    on_hold_offer = product1.offers.create!(status: "on_hold", current: true)
    accepted_offer = product2.offers.create!(status: "accepted", current: false)
    offer1 = product1.offers.create!(status: "on_hold", current: "true")
    offer2 = product2.offers.create!(status: "accepted", current: "false")

    store = {product1: product1, product2: product2,
             offer1: offer1,
             available_offer: available_offer,
             on_hold_offer: on_hold_offer}
  end

  describe "#complete" do
    it "sets status to accepted" do
      offer = setup_store[:offer1]

      offer.complete

      expect(offer.status).to eql("accepted")
    end
    it "sets current to false" do
      offer = setup_store[:offer1]

      offer.complete

      expect(offer.current).to be false
    end
    it "increments number_sold for its corresponding product" do
      offer = setup_store[:offer1]

      offer.complete

      expect(offer.product.number_sold).to eql(1)
    end
    it "increments number_sold for its corresponding product (version 2)" do
      offer = setup_store[:offer1]

      expect { offer.complete }.to change(offer.product, :number_sold).from(0).to(1)
    end
  end

  describe "#release_hold" do
    it "removes the corresponding order" do
      offer = setup_store[:on_hold_offer]
      order = offer.create_order!(product_id: offer.product_id, checkout_session: "abc123")
      allow(StripeCheckoutsService).to receive(:expire_session)

      offer.release_hold

      expect { order.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
    it "sets its status to available" do
      offer = setup_store[:on_hold_offer]
      order = offer.create_order!(product_id: offer.product_id, checkout_session: "abc123")
      allow(StripeCheckoutsService).to receive(:expire_session)

      offer.release_hold

      expect(offer.status).to eql("available")
    end
    it "calls the StripeCheckoutService expire_session method and passes the checkout_session as an argument" do
      offer = setup_store[:on_hold_offer]
      order = offer.create_order!(product_id: offer.product_id, checkout_session: "abc123")

      expect(StripeCheckoutsService).to receive(:expire_session).with("abc123")

      offer.release_hold
    end
  end

  describe "#create_checkout" do
    it "calls prepare_for_checkout method" do
      offer = setup_store[:available_offer]
      expect(offer).to receive(:prepare_for_checkout)

      offer.create_checkout
    end
    it "creates a new order" do
      offer = setup_store[:available_offer]

      expect { offer.create_checkout }.to change { Order.count }.by(1)
    end
    it "updates its status to on_hold" do
      offer = setup_store[:available_offer]
      expect { offer.create_checkout }.to change(offer, :status).from("available").to("on_hold")
    end
    it "calls the StripeCheckoutsService create_session method" do
      offer = setup_store[:available_offer]
      expect(StripeCheckoutsService).to receive(:create_session)
      offer.create_checkout
    end
  end

  describe "#eligible_for_checkout?" do
    it "returns true when current is true and status is available" do
      offer = setup_store[:product1].offers.create!(status: "available", current: true)

      expect(offer.eligible_for_checkout?).to be true
    end
    it "returns true when current is true and hold is expired" do
      offer = setup_store[:product1].offers.create!(status: "on_hold", current: true)
      allow(offer).to receive(:hold_expired?) { true }

      expect(offer.eligible_for_checkout?).to be true
    end
    it "returns false when current is true and hold is not expired" do
      offer = setup_store[:product1].offers.create!(status: "on_hold", current: true)
      allow(offer).to receive(:hold_expired?) { false }

      expect(offer.eligible_for_checkout?).to be false
    end
    it "returns false when current is false" do
      offer = setup_store[:product1].offers.create!(status: "available", current: false)

      expect(offer.eligible_for_checkout?).to be false
    end
  end

  describe "#hold_expired?" do
    it "returns true when on_hold and cart_time_limit_exceeded? are both true" do
      offer = setup_store[:offer1]
      allow(offer).to receive(:cart_time_limit_exceeded?) { true }

      expect(offer.hold_expired?).to be true
    end
    it "returns false when cart_time_limit_exceeded? is false" do
      offer = setup_store[:offer1]
      allow(offer).to receive(:cart_time_limit_exceeded?) { false }

      expect(offer.hold_expired?).to be false
    end
    it "returns false when status is available" do
      offer = setup_store[:offer1]
      offer.status = "available"
      allow(offer).to receive(:cart_time_limit_exceeded?) { true }

      expect(offer.hold_expired?).to be false
    end
    it "returns false when status is accepted" do
      offer = setup_store[:offer1]
      offer.status = "accepted"
      allow(offer).to receive(:cart_time_limit_exceeded?) { true }

      expect(offer.hold_expired?).to be false
    end
  end
end
