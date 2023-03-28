class StripeCheckoutsService
  include Rails.application.routes.url_helpers

  SessionResult = Struct.new(:url, :id, keyword_init: true)

  def self.expire_session(session_id)
    checkout_session = Stripe::Checkout::Session.retrieve(session_id)
    if checkout_session.status == "open"
      Stripe::Checkout::Session.expire(session_id)
    end
  end

  def self.create_session(order_id:, product_name:, product_price:)
    stripe_checkout_session = Stripe::Checkout::Session.create({
      client_reference_id: order_id,
      phone_number_collection: {
        enabled: true
      },
      shipping_address_collection: {
        allowed_countries: ["US"]
      },
      line_items: [{
        price_data: {
          currency: "usd",
          product_data: {
            name: product_name
          },
          unit_amount: product_price
        },
        quantity: 1
      }],
      mode: "payment",
      success_url: Rails.application.routes.url_helpers.root_url + "checkout_success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: Rails.application.routes.url_helpers.root_url + "cancel_checkout?session_id={CHECKOUT_SESSION_ID}"
    })
    SessionResult.new(url: stripe_checkout_session.url, id: stripe_checkout_session.id)
  end

  def self.checkout_session_url(session_id)
    checkout_session = Stripe::Checkout::Session.retrieve(session_id)
    checkout_session.url
  end

  def self.retrieve_completed_checkout_details(session_id)
    checkout_details = {}
    checkout_session = Stripe::Checkout::Session.retrieve(session_id)
    if checkout_session.status == "complete"
      checkout_details = {name: checkout_session.shipping_details.name,
                          address_line1: checkout_session.shipping_details.address.line1,
                          address_line2: checkout_session.shipping_details.address.line2,
                          address_city: checkout_session.shipping_details.address.city,
                          address_state: checkout_session.shipping_details.address.state,
                          address_zip: checkout_session.shipping_details.address.postal_code,
                          email: checkout_session.customer_details.email,
                          phone_number: checkout_session.customer_details.phone,
                          status: checkout_session.payment_status}
    end
    checkout_details
  end
end
