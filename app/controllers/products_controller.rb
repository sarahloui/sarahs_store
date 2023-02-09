class ProductsController < ApplicationController
  def home
      @product = Product.first
  end
end
