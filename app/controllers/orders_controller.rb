class OrdersController < ApplicationController
  def new
    @order = Order.new
    @product = Product.find(params[:product])
  end

  def create
    price = params[:price_amount]
    product_title = params[:product_name]
    session = Stripe::Checkout::Session.create({
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: product_title,
            },
            unit_amount: price,
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: root_url + 'orders/success',
      cancel_url: root_url + 'orders/cancel',
    })
    redirect_to session.url, allow_other_host: true
  end

  def show
    @order = Order.find(params[:id])
  end

  def cancel
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
