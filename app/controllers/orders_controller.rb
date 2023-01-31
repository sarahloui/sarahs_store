class OrdersController < ApplicationController
  MAX_CART_HOLD_TIME = 300

  def show
    @order = Order.find(params[:id])
  end

  def cancel
    order = Order.find_by(checkout_session: params[:session_id])
    if (order!=nil && order.status==nil)
      order.offer.available!
      order.delete
      flash[:alert]="Checkout session cancelled"
      # expire stripe checkout session?
    end
      redirect_to root_url
  end

  def order_params
    params.require(:order).permit(:name,
                                  :address_line1,
                                  :address_line2,
                                  :address_city,
                                  :address_state,
                                  :address_zip,
                                  :email,
                                  :phone_number,
                                  :checkout_session)

  end

end
