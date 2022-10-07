class ProductsController < ApplicationController
  def home
      @product = Product.first
  end

  def show
    @product = Product.find(params[:id])
  end

end
