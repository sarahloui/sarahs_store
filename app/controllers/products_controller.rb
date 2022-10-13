class ProductsController < ApplicationController
  def home
      @product = Product.second
  end

  def show
    @product = Product.find(params[:id])
  end

end
