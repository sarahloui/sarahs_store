require 'rails_helper'

describe "the store homepage", type: :feature do
  before :each do
    @product1 = Product.create!(name: "Apron", description: "Red apron", price: 1234, status: "available")
    @product2 = Product.create!(name: "Blouse", description: "Silk blouse", price: 5678, status: "available")
    @product3 = Product.create!(name: "Coat", description: "Winter coat", price: 9900, status: "available" )
  end

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
end
