require "rails_helper"

describe "checkout", type: :feature do
  context "when a user attempts to accept an offer that is not current" do
    it "redirects to the home page" do
      offer = create(:current_available_offer)

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
        offer = create(:current_available_offer)

        visit root_url
        offer.update!(status: "on_hold", start_time: DateTime.now)
        click_on "Buy Now!"

        expect(page).to have_text("The item you selected is in the process of being checked out. Please check back in a few minutes.")
        expect(page).to have_current_path(root_url)
      end
    end
    context "where the hold time has elapsed" do
      it "allows for a completed order" do
        order = create(:incomplete_order, checkout_session: "9999")
        offer = order.offer
        offer.update!(current: true, status: "on_hold", start_time: 2.hours.ago)
        allow(StripeCheckoutsService).to receive(:expire_session)
        allow(StripeCheckoutsService).to receive(:create_session) do
          StripeCheckoutsService::SessionResult.new(
            url: Rails.application.routes.url_helpers.root_url + "checkout_success?session_id=abc123",
            id: "abc123"
          )
        end
        allow(StripeCheckoutsService).to receive(:retrieve_completed_checkout_details) do
          checkout_details = {name: "Ben", address_line1: "345 Kana St", status: "paid"}
        end

        visit root_url
        click_on "Buy Now!"

        expect(page).to have_text("Thank you for your order, Ben!")
        expect(page).to have_text("Dress")
        expect(page).to have_current_path(root_path + "checkout_success?session_id=abc123")
      end
    end
  end

  context "when a current offer exists" do
    it "allows for a completed order" do
      offer = create(:current_available_offer)
      allow(StripeCheckoutsService).to receive(:create_session) do
        StripeCheckoutsService::SessionResult.new(url: Rails.application.routes.url_helpers.root_url + "checkout_success?session_id=abc123", id: "abc123")
      end
      allow(StripeCheckoutsService).to receive(:retrieve_completed_checkout_details) do
        checkout_details = {name: "Ann", address_line1: "345 Kana St", status: "paid"}
      end

      visit root_url
      click_on "Buy Now!"

      expect(page).to have_text("Thank you for your order, Ann!")
      expect(page).to have_text("Dress")
      expect(page).to have_current_path(root_path + "checkout_success?session_id=abc123")
    end
    it "allows for a cancelled checkout" do
      offer = create(:current_available_offer)
      allow(StripeCheckoutsService).to receive(:create_session) do
        StripeCheckoutsService::SessionResult.new(url: Rails.application.routes.url_helpers.root_url + "cancel_checkout?session_id=abc123", id: "abc123")
      end
      allow(StripeCheckoutsService).to receive(:expire_session)

      visit root_url
      click_on "Buy Now!"

      expect(page).to have_text("Description: Silk dress")
      expect(page).to have_button("Buy Now!", disabled: false)
      expect(page).to have_current_path(root_path)
    end
  end
end
