require "rails_helper"

describe "Order", type: :model do
  def setup_store
    product1 = Product.create!(name: "Apron", description: "Red apron", price: 1234, number_sold: 0)
    product2 = Product.create!(name: "Blouse", description: "Silk blouse", price: 5678, number_sold: 0)
    offer1 = product1.offers.create!(status: "on_hold", current: "true")
    offer2 = product2.offers.create!(status: "accepted", current: "false")
    order1 = offer1.create_order!(product_id: offer1.product_id)
    order2 = offer2.create_order!(product_id: offer2.product_id, status: "paid", name: "Chandler Bing", address_line1: "99 Olive St")

    store = {product1: product1, product2: product2, offer1: offer1, order1: order1, order2: order2}
  end

  describe "#complete" do
    context "when order status is nil" do
      it "returns true" do
        order1 = setup_store[:order1]
        checkout_details = {name: "Rachel Green", address_line1: "123 10th Ave", status: "paid"}

        expect(order1.complete(checkout_details)).to be true
      end
      it "updates attributes with corresponding checkout details" do
        order1 = setup_store[:order1]
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

        order1.complete(checkout_details)

        expect(order1.name).to eql("Rachel Green")
        expect(order1.address_line1).to eql("123 10th Ave")
        expect(order1.address_line2).to eql("Apt 5")
        expect(order1.address_city).to eql("Honolulu")
        expect(order1.address_state).to eql("HI")
        expect(order1.email).to eql("rgreen@example.com")
        expect(order1.phone_number).to eql("+18082222222")
        expect(order1.status).to eql("paid")
      end
      it "should call offer.complete" do
        order1 = setup_store[:order1]
        offer1 = order1.offer
        checkout_details = {name: "Rachel Green", address_line1: "123 10th Ave", status: "paid"}

        expect(offer1).to receive(:complete)

        order1.complete(checkout_details)
      end
    end

    context "when order status is not nil" do
      it "returns false" do
        order1 = setup_store[:order1]
        order1.status = "paid"
        checkout_details = {name: "Rachel Green", address_line1: "123 10th Ave", status: "paid"}

        expect(order1.complete(checkout_details)).to be false
      end

      it "does not update attributes with checkout details" do
        order = setup_store[:order2]
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
        expect(order.status).to eql("paid")
      end
    end
  end
end
