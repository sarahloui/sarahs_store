require 'rails_helper'

describe "the store homepage", type: :feature do
  before :each do
    @product1 = Product.create!(name: "Apron", description: "Red apron", price: 1234, number_sold:0)
    @product2 = Product.create!(name: "Blouse", description: "Silk blouse", price: 5678, number_sold:0)
    @product3 = Product.create!(name: "Coat", description: "Winter coat", price: 9900, number_sold:0)
    @product4 = Product.create!(name: "Dress", description: "Denim dress", price: 10000, number_sold: 0)
  end

  context "when there are no current offers" do
    it "doesn't display an offer" do
      visit root_url
      expect(page).to have_text("No offer is currently available")
    end
  end

  context "when a current offer exists" do
    it "displays the current offer with correct product details" do
      @product1.offers.create!(status: "available", current: "true")
      visit root_url
      expect(page).to have_text("Apron")
      expect(page).to have_text("Description: Red apron")
      expect(page).to have_text("Price: $12.34")
      expect(page).to have_button("Buy Now!")
    end
  end
end

=begin

  context "when all products are available" do
    it "displays the first unsold product" do
      visit '/products/home'
      expect(page).to have_text("Apron")
      expect(page).to have_text("Description: ")
      expect(page).to have_text("Price: ")
      expect(page).to have_button("Buy Now!")
    end
  end

  context "when all products are sold" do
    it "doesn't display any products" do
      @product1.update!(status: "sold")
      @product2.update!(status: "sold")
      @product3.update!(status: "sold")
      visit "/products/home"
      expect(page).to have_text("No Products to display")
    end
  end

  context "when one product is sold" do
    it "displays the next unsold product" do
      @product1.update!(status: "sold")
      visit "/products/home"
      expect(page).to have_text("Blouse")
    end
  end

  context "when a product is on hold" do
    it "displays that product" do
      @product1.update!(status: "on_hold")
      visit "/products/home"
      expect(page).to have_text("Apron")
    end
  end
=end
