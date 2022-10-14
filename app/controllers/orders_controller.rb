class OrdersController < ApplicationController
  def new
    @order = Order.new
    @product = Product.find(params[:product])
  end

  def create
    # Find Product to Buy
    product = Product.find(params[:product_id])

     #Check that product is not already associated with an order
    if product.order!=nil
      #Check that product hasn't been purchased already
      if product.status == "sold"
        flash[:alert] = "Sorry, the item that you selected is sold and is no longer available for purchase"
        redirect_to root_url and return
      elsif product.status =="on hold"
        #Product has been in other users cart for less than 5 minutes
        if product.order.created_at.since(300)>DateTime.now
          flash[:alert] = "The item you selected is currently on hold, please try again in a few minutes"
          redirect_to root_url and return
        else
          #expire checkout session and delete order if 5 minutes has elasped
          #Find matching checkout session and expire it if it's still open
          checkout_session_to_expire =Stripe::Checkout::Session.retrieve(product.order.checkout_session)
          if checkout_session_to_expire.status == "open"
            Stripe::Checkout::Session.expire(product.order.checkout_session)
          end
          product.order.delete
          product.update(status: "available")
        end
      end
    end

    # New order with matching product
    order = product.build_order

    if order.save
      product.update(status: "on hold")
      checkout_session = Stripe::Checkout::Session.create({
        client_reference_id: order.id,
        phone_number_collection: {
          enabled: true
        },
        shipping_address_collection: {
        allowed_countries: ['US']
        },
        line_items: [{
          price_data: {
            currency: 'usd',
            product_data: {
              name: product.name,
            },
            unit_amount: product.price,
          },
          quantity: 1,
        }],
        mode: 'payment',
        success_url: root_url + 'orders/success?session_id={CHECKOUT_SESSION_ID}',
        cancel_url: root_url + 'orders/cancel?session_id={CHECKOUT_SESSION_ID}'
      })
      order.update(checkout_session: checkout_session.id)
      redirect_to checkout_session.url, allow_other_host: true
    else
      redirect_to root_url
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  def cancel
    incomplete_checkout_session = Stripe::Checkout::Session.retrieve(params[:session_id])
    order = Order.find_by(id: incomplete_checkout_session.client_reference_id)
    if (order!=nil && order.checkout_session==incomplete_checkout_session.id && order.status==nil)
      order.delete
      flash[:alert]="Checkout session cancelled"
    else
      flash[:alert]="No matching checkout session to cancel"
    end
    redirect_to root_url
  end

  def success
    @completed_checkout_session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @item_sold = Stripe::Checkout::Session.list_line_items(params[:session_id]).data[0]
    order = Order.find_by(id: @completed_checkout_session.client_reference_id)
    if (order.checkout_session == @completed_checkout_session.id)
      product = order.product
      if !order.update(name: @completed_checkout_session.shipping_details.name,
                      address_line1: @completed_checkout_session.shipping_details.address.line1,
                      address_line2: @completed_checkout_session.shipping_details.address.line2,
                      address_city: @completed_checkout_session.shipping_details.address.city,
                      address_state: @completed_checkout_session.shipping_details.address.state,
                      address_zip: @completed_checkout_session.shipping_details.address.postal_code,
                      email: @completed_checkout_session.customer_details.email,
                      phone_number: @completed_checkout_session.customer_details.phone,
                      status: @completed_checkout_session.payment_status) || !product.update(status: "sold")
        flash[:alert]="Order could not be saved"
        redirect_to root_url
      end
    end
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
