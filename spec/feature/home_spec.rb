require "rails_helper"
require "support/time_helpers"

describe "the store homepage", type: :feature do
  context "when there are no current offers" do
    it "doesn't display an offer" do
      visit root_url
      expect(page).to have_text("No offer is currently available")
    end
  end

  context "when a current and available offer exists" do
    it "displays the current offer with correct product details" do
      create(:current_available_offer)
      visit root_url
      expect(page).to have_text("Dress")
      expect(page).to have_text("Silk dress")
      expect(page).to have_text("Price: $79.50")
      expect(page).to have_button("Buy Now!", disabled: false)
    end
  end

  context "when an offer is on hold and the hold time hasn't expired " do
    it "displays the offer with correct product details and disabled buy button" do
      create(:offer_with_valid_hold)
      visit root_url
      expect(page).to have_text("Dress")
      expect(page).to have_text("Silk dress")
      expect(page).to have_text("Price: $79.50")
      expect(page).to have_button("Buy Now!", disabled: true)
    end
  end

  context "when an offer is on hold and the hold time has elapsed " do
    it "displays the offer with correct product details and enabled buy button" do
      create(:offer_with_expired_hold)
      visit root_url
      expect(page).to have_text("Dress")
      expect(page).to have_text("Silk dress")
      expect(page).to have_text("Price: $79.50")
      expect(page).to have_button("Buy Now!", disabled: false)
    end
  end
end
