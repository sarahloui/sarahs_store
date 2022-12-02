class ProductsController < ApplicationController
  def home
      @product = Product.where.not(status: "sold").first
  end

  def show
    @product = Product.find(params[:id])
  end
end
