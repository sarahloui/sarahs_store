class OffersController < ApplicationController
  def create(product_id=nil)
    if product_id.nil?
      product = Product.order(:updated_at).first
    else
      product = Product.find(product_id)
    end
    offer = product.offers.build(status:"available", current: "true")
    offer.save
  end

  def home
    @offer=Offer.where(current: true).last
  end

# Check that the offer is available and create a new order
  def accept(offer_id=nil)
    if offer_id.nil?
      offer_id = params[:offer_id]
    end

    offer = Offer.find(offer_id)
    if !offer.current
      flash[:alert] = "The item you selected is no longer available"
      redirect_to root_url and return
    elsif offer.on_hold?
      flash[:alert] = "The item you selected is in the process of being checked out. Please check back in a few minutes."
      redirect_to root_url and return
    end
    if offer.available? && offer.current?
      order = offer.build_order(product_id: offer.product_id)
      order.save
      offer.on_hold!
      offer.update(start_time: DateTime.now)

      # launch Stripe checkout session
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
              name: offer.product.name,
            },
            unit_amount: offer.product.price,
          },
          quantity: 1,
        }],
        mode: 'payment',
        success_url: root_url + 'orders/success?session_id={CHECKOUT_SESSION_ID}',
        cancel_url: root_url + 'orders/cancel?session_id={CHECKOUT_SESSION_ID}'
      })
      order.update(checkout_session: checkout_session.id)
      redirect_to checkout_session.url, allow_other_host: true
    end
  end

  def complete(offer_id=nil)
    offer = Offer.find(offer_id)
    offer.update(status: 2, current:"false")
    # increment number_sold?
    self.create
  end

  def validate
  end

end
