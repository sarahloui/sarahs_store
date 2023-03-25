require "rails_helper"

describe "checkout", type: :feature do
  def setup_store
    product1 = Product.create!(name: "Apron", description: "Red apron", price: 1234, number_sold: 0)
    product2 = Product.create!(name: "Blouse", description: "Silk blouse", price: 5678, number_sold: 0)
    offer1 = product1.offers.create!(status: "available", current: "true")
    store = {product1: product1, product2: product2, offer1: offer1}
  end

  context "when a user attempts to accept an offer that is not current" do
    it "redirects to the home page" do
      offer = setup_store[:offer1]

      visit root_url
      offer.update!(current: "false")
      click_on "Buy Now!"

      expect(page).to have_text("The item you selected is no longer available")
      expect(page).to have_current_path(root_url)
    end
  end

  context "when a user attempts to accept an offer that is on hold" do
    context "where the hold time has not elapsed" do
      it "redirects to the homepage" do
        offer = setup_store[:offer1]

        visit root_url
        offer.update!(status: "on_hold", start_time: DateTime.now)
        click_on "Buy Now!"

        expect(page).to have_text("The item you selected is in the process of being checked out. Please check back in a few minutes.")
        expect(page).to have_current_path(root_url)
      end
    end
    context "where the hold time has elapsed" do
      it "allows for a completed order" do
        offer = setup_store[:offer1]
        old_order = offer.create_order!(product_id: offer.product_id, checkout_session: "ab12")
        offer.update!(status: "on_hold", start_time: DateTime.now - Offer::MAX_CART_HOLD_TIME)
        allow(StripeCheckoutsService).to receive(:expire_session)
        allow(StripeCheckoutsService).to receive(:create_session) do |order|
          order.update(checkout_session: "cde")
          Rails.application.routes.url_helpers.root_url + "checkout_success?session_id=cde"
        end
        allow(StripeCheckoutsService).to receive(:retrieve_completed_checkout_details) do
          checkout_details = {name: "Ben", address_line1: "345 Kana St", status: "paid"}
        end

        visit root_url
        click_on "Buy Now!"

        expect(page).to have_text("Thank you for your order, Ben!")
        expect(page).to have_text("Apron")
        expect(page).to have_current_path(root_path + "checkout_success?session_id=cde")
      end
    end
  end

  context "when a current offer exists" do
    it "allows for a completed order" do
      setup_store
      allow(StripeCheckoutsService).to receive(:create_session) do |order|
        order.update(checkout_session: "123")
        Rails.application.routes.url_helpers.root_url + "checkout_success?session_id=123"
      end
      allow(StripeCheckoutsService).to receive(:retrieve_completed_checkout_details) do
        checkout_details = {name: "Ann", address_line1: "345 Kana St", status: "paid"}
      end

      visit root_url
      click_on "Buy Now!"

      expect(page).to have_text("Thank you for your order, Ann!")
      expect(page).to have_text("Apron")
      expect(page).to have_current_path(root_path + "checkout_success?session_id=123")
    end

    it "allows for a cancelled checkout" do
      setup_store
      allow(StripeCheckoutsService).to receive(:create_session) do |order|
        order.update(checkout_session: "456")
        Rails.application.routes.url_helpers.root_url + "cancel_checkout?session_id=456"
      end
      allow(StripeCheckoutsService).to receive(:expire_session)

      visit root_url
      click_on "Buy Now!"

      expect(page).to have_text("Description: Red apron")
      expect(page).to have_button("Buy Now!", disabled: false)
      expect(page).to have_current_path(root_path)
    end
  end
end
