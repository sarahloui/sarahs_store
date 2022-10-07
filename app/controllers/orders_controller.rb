class OrdersController < ApplicationController
  def new
    @order = Order.new
    @product = Product.find(params[:product])
  end

  def create
    @product= Product.find(params[:product])
    @order = Order.new
    @order = @product.build_order(order_params)
    if @order.save
      redirect_to @order
    else
     render 'new', status: :unprocessable_entity
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:first_name,
                                  :last_name,
                                  :address_street,
                                  :address_city,
                                  :address_state,
                                  :address_zip,
                                  :email,
                                  :phone_number)

  end

end
