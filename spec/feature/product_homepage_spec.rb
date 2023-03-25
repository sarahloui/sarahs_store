require "rails_helper"

describe "the store homepage", type: :feature do
  def setup_product
    product1 = Product.create!(name: "Apron", description: "Red apron", price: 1234, number_sold: 0)
    product2 = Product.create!(name: "Blouse", description: "Silk blouse", price: 5678, number_sold: 0)
    product3 = Product.create!(name: "Coat", description: "Winter coat", price: 9900, number_sold: 0)
    product4 = Product.create!(name: "Dress", description: "Denim dress", price: 10000, number_sold: 0)
    products = {product1: product1, product2: product2, product3: product3, product4: product4}
  end

  context "when there are no current offers" do
    it "doesn't display an offer" do
      visit root_url
      expect(page).to have_text("No offer is currently available")
    end
  end

  context "when a current offer exists" do
    it "displays the current offer with correct product details" do
      product = setup_product[:product1]
      product.offers.create!(status: "available", current: "true")
      visit root_url
      expect(page).to have_text("Apron")
      expect(page).to have_text("Description: Red apron")
      expect(page).to have_text("Price: $12.34")
      expect(page).to have_button("Buy Now!", disabled: false)
    end
  end

  context "when an offer is on hold and unavailable for checkout" do
    it "displays the offer with correct product details" do
      setup_product[:product1].offers.create!(status: "on_hold", current: "true", start_time: DateTime.now)
      visit root_url
      expect(page).to have_text("Apron")
      expect(page).to have_text("Description: Red apron")
      expect(page).to have_text("Price: $12.34")
      expect(page).to have_button("Buy Now!", disabled: true)
    end
  end

  context "when an offer is on hold and available for checkout" do
    it "displays the offer with correct product details" do
      setup_product[:product1].offers.create!(status: "on_hold", current: "true", start_time: DateTime.now.since(-Offer::MAX_CART_HOLD_TIME))
      visit root_url
      expect(page).to have_text("Apron")
      expect(page).to have_text("Description: Red apron")
      expect(page).to have_text("Price: $12.34")
      expect(page).to have_button("Buy Now!", disabled: false)
    end
  end

  context "when a current offer exists" do
    it "displays the current offer with correct product details and allows for a successful checkout" do
      product = setup_product[:product1]
      product.offers.create!(status: "available", current: "true")
      allow(StripeCheckoutsService).to receive(:create_session) do |order|
        order.update(checkout_session: "123")
        Rails.application.routes.url_helpers.root_url + "checkout_success?session_id=123"
      end
      allow(StripeCheckoutsService).to receive(:retrieve_completed_checkout_details) do
        checkout_details = {name: "Ann", address_line1: "345 Kana St", status: "paid"}
      end

      visit root_url
      click_on "Buy Now!"

      expect(page).to have_text("Thank you")
      expect(page).to have_text("345 Kana St")
    end
  end
end
