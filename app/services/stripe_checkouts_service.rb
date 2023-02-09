class StripeCheckoutsService
  include Rails.application.routes.url_helpers
  def expire_stripe_session(session_id)
    checkout_session = Stripe::Checkout::Session.retrieve(session_id)
    if checkout_session.status=="open"
      Stripe::Checkout::Session.expire(session_id)
    end
  end

  def create_stripe_checkout_session(order_id)
    order = Order.find(order_id)
    puts "order_id: "
    puts order.id
    puts order.offer.product.name
    @blah=Stripe::Checkout::Session.create({
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
            name: order.offer.product.name,
          },
          unit_amount: order.offer.product.price,
        },
        quantity: 1,
      }],
      mode: 'payment',
      # success_url: "https://google.com",
      # cancel_url: "https://youtube.com"
       success_url: root_url + 'checkout_success?session_id={CHECKOUT_SESSION_ID}',
       cancel_url: root_url + 'cancel_checkout?session_id={CHECKOUT_SESSION_ID}'
    })
    order.update(checkout_session: @blah.id)
    puts @blah.id
    puts @blah.url
    # redirect_to @blah.url, allow_other_host: true, data: { turbo: false }
  end

  def checkout_session_url(session_id)
    checkout_session = Stripe::Checkout::Session.retrieve(session_id)
    return checkout_session.url
  end

  def retrieve_stripe_completed_checkout_details(session_id=nil)
    if session_id.nil?
      session_id=params[:session_id]
    end
    checkout_session = Stripe::Checkout::Session.retrieve(session_id)
    if checkout_session.status=="complete"
      name = checkout_session.shipping_details.name
      address_line1 = checkout_session.shipping_details.address.line1,
      address_line2 = checkout_session.shipping_details.address.line2,
      address_city = checkout_session.shipping_details.address.city,
      address_state = checkout_session.shipping_details.address.state,
      address_zip = checkout_session.shipping_details.address.postal_code,
      email= checkout_session.customer_details.email,
      phone_number= checkout_session.customer_details.phone,
      status= checkout_session.payment_status
    end
  end
end
