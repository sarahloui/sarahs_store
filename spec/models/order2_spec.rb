require "rails_helper"

describe "Order", type: :model do
  describe "#complete" do
    context "when order status is nil" do
      it "returns true" do
        order = create(:incomplete_order)
        checkout_details = {name: "Rachel Green", address_line1: "123 10th Ave", status: "paid"}

        expect(order.complete(checkout_details)).to be true
      end
      it "updates attributes with corresponding checkout details" do
        order = create(:incomplete_order)
        checkout_details = {
          name: "Rachel Green",
          address_line1: "123 10th Ave",
          address_line2: "Apt 5",
          address_city: "Honolulu",
          address_state: "HI",
          address_zip: "96815",
          email: "rgreen@example.com",
          phone_number: "+18082222222",
          status: "paid"
        }

        order.complete(checkout_details)

        expect(order.name).to eql("Rachel Green")
        expect(order.address_line1).to eql("123 10th Ave")
        expect(order.address_line2).to eql("Apt 5")
        expect(order.address_city).to eql("Honolulu")
        expect(order.address_state).to eql("HI")
        expect(order.email).to eql("rgreen@example.com")
        expect(order.phone_number).to eql("+18082222222")
        expect(order.status).to eql("paid")
      end
      it "should call offer.complete" do
        order = create(:incomplete_order)
        offer = order.offer
        checkout_details = {name: "Rachel Green", address_line1: "123 10th Ave", status: "paid"}

        expect(offer).to receive(:complete)

        order.complete(checkout_details)
      end
    end

    context "when order status is not nil" do
      it "returns false" do
        order = create(:order, :completed)
        checkout_details = {name: "Rachel Green", address_line1: "123 10th Ave", status: "paid"}

        expect(order.complete(checkout_details)).to be false
      end

      it "does not update attributes with checkout details" do
        order = create(:order, :completed, name: "Chandler Bing", address_line1: "99 Olive St", status: "paid")
        checkout_details = {
          name: "Rachel Green",
          address_line1: "123 10th Ave",
          address_line2: "Apt 5",
          address_city: "Honolulu",
          address_state: "HI",
          address_zip: "96815",
          email: "rgreen@example.com",
          phone_number: "+18082222222",
          status: "unpaid"
        }

        order.complete(checkout_details)

        expect(order.name).to eql("Chandler Bing")
        expect(order.address_line1).to eql("99 Olive St")
        expect(order.address_line2).to eql(nil)
        expect(order.status).to eql("paid")
      end
    end
  end
end
