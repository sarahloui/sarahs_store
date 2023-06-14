require "rails_helper"
require "support/time_helpers"

describe "Offer", type: :model do
  describe "#complete" do
    it "sets status to accepted and current to false" do
      offer = create(:offer, status: "on_hold", current: true)

      offer.complete

      expect(offer.status).to eql("accepted")
      expect(offer.current).to be false
    end
    it "increments number_sold by 1 for its corresponding product" do
      offer = create(:on_hold_offer)

      expect { offer.complete }.to change(offer.product, :number_sold).from(0).to(1)
    end
  end

  describe "#release_hold" do
    it "removes the corresponding order" do
      offer = create(:offer)
      order = create(:order, :incomplete, offer: offer)
      allow(StripeCheckoutsService).to receive(:expire_session)

      offer.release_hold

      expect { order.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
    it "sets its status to available" do
      offer = create(:offer, status: "on_hold")
      order = create(:order, :incomplete, offer: offer)
      allow(StripeCheckoutsService).to receive(:expire_session)

      offer.release_hold

      expect(offer.status).to eql("available")
    end
    it "calls the StripeCheckoutService expire_session method and passes the checkout_session as an argument" do
      offer = create(:offer)
      order = create(:order, :incomplete, checkout_session: "abc123", offer: offer)

      expect(StripeCheckoutsService).to receive(:expire_session).with("abc123")

      offer.release_hold
    end
  end

  describe "#create_checkout" do
    it "calls the prepare_for_checkout method" do
      offer = create(:offer)
      expect(offer).to receive(:prepare_for_checkout)
      allow(StripeCheckoutsService).to receive(:create_session) do
        StripeCheckoutsService::SessionResult.new(url: "pay.com", id: "cde123")
      end

      offer.create_checkout
    end
    it "creates a new order" do
      offer = create(:offer)
      allow(StripeCheckoutsService).to receive(:create_session) do
        StripeCheckoutsService::SessionResult.new(url: "pay.com", id: "cde123")
      end

      expect { offer.create_checkout }.to change { Order.count }.by(1)
      expect(offer.order.product_id).to eql(offer.product_id)
    end
    it "updates order's checkout_session attribute with the stripe checkout id" do
      offer = create(:current_available_offer)
      allow(StripeCheckoutsService).to receive(:create_session) do
        StripeCheckoutsService::SessionResult.new(url: "pay.com", id: "cde123")
      end

      offer.create_checkout

      expect(offer.order.checkout_session).to eql("cde123")
    end
    it "updates status to on_hold" do
      offer = create(:offer, status: "available")
      allow(StripeCheckoutsService).to receive(:create_session) do
        StripeCheckoutsService::SessionResult.new(url: "pay.com", id: "cde123")
      end

      offer.create_checkout

      expect(offer.status).to eql("on_hold")
    end
    it "sets the start time to the current time" do
      offer = create(:current_available_offer)
      allow(StripeCheckoutsService).to receive(:create_session) do
        StripeCheckoutsService::SessionResult.new(url: "pay.com", id: "cde123")
      end
      freeze_time do
        offer.create_checkout
        expect(offer.start_time).to be_within(1.second).of(DateTime.now)
      end
    end
    it "calls the StripeCheckoutsService create_session method" do
      offer = create(:current_available_offer)
      allow(StripeCheckoutsService).to receive(:create_session) do
        StripeCheckoutsService::SessionResult.new(url: "pay.com", id: "cde123")
      end

      expect(StripeCheckoutsService).to receive(:create_session).with(order_id: 1, product_name: "Dress", product_price: 7950)

      offer.create_checkout
    end
  end

  describe "#eligible_for_checkout?" do
    it "returns true when current is true and status is available" do
      offer = create(:offer, current: true, status: "available")

      expect(offer.eligible_for_checkout?).to be true
    end
    it "returns true when current is true and hold is expired" do
      offer = create(:offer, current: true, status: "on_hold")
      allow(offer).to receive(:hold_expired?) { true }

      expect(offer.eligible_for_checkout?).to be true
    end
    it "returns false when current is true and hold is not expired" do
      offer = create(:offer, current: true, status: "on_hold")
      allow(offer).to receive(:hold_expired?) { false }

      expect(offer.eligible_for_checkout?).to be false
    end
    it "returns false when current is false" do
      offer = create(:offer, current: false)

      expect(offer.eligible_for_checkout?).to be false
    end
  end

  describe "#hold_expired?" do
    it "returns true when on_hold and cart_time_limit_exceeded? are both true" do
      offer = create(:on_hold_offer)
      allow(offer).to receive(:cart_time_limit_exceeded?) { true }

      expect(offer.hold_expired?).to be true
    end
    it "returns false when cart_time_limit_exceeded? is false" do
      offer = create(:on_hold_offer)
      allow(offer).to receive(:cart_time_limit_exceeded?) { false }

      expect(offer.hold_expired?).to be false
    end
    it "returns false when status is available" do
      offer = create(:offer, status: "available")
      allow(offer).to receive(:cart_time_limit_exceeded?) { true }

      expect(offer.hold_expired?).to be false
    end
    it "returns false when status is accepted" do
      offer = create(:offer, status: "accepted")
      allow(offer).to receive(:cart_time_limit_exceeded?) { true }

      expect(offer.hold_expired?).to be false
    end
  end

  describe "#cart_time_limit_exceeded?" do
    it "returns true when the time elapsed since the start time of the offer exceeds the max cart hold time" do
      offer = create(:offer, start_time: 2.hours.ago)
      expect(offer.cart_time_limit_exceeded?).to be true
    end
    it "returns false when the time elapsed since the start time of the offer is less than the max cart hold time" do
      offer = create(:offer, start_time: 10.seconds.ago)
      expect(offer.cart_time_limit_exceeded?).to be false
    end
  end
end
