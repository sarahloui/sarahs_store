class OffersController < ApplicationController

  skip_before_action :verify_authenticity_token
  
  def create(product_id=nil)
    if product_id.nil?
      product = Product.order(:updated_at).first
    else
      product = Product.find(product_id)
    end
    @offer = product.offers.build(status:"available", current: "true")
    @offer.save
    Turbo::StreamsChannel.broadcast_update_to("home", target: "current_offer", partial:"offers/offer", locals:{offer: @offer})
    Turbo::StreamsChannel.broadcast_update_to("home", target: "buy_button", partial:"offers/buy_button", locals:{offer: @offer})
  end

  def home
    @offer=Offer.where(current: true).last
  end

  def accept(offer_id=nil)
    if offer_id.nil?
      offer_id = params[:offer_id]
    end
    @offer = Offer.find(offer_id)
    if @offer.current==false
      flash[:alert] = "The item you selected is no longer available"
      redirect_to root_url and return
    end
    if @offer.on_hold?
      if @offer.cart_time_limit_exceeded?
        self.release_hold(offer_id)
      else
        flash[:alert] = "The item you selected is in the process of being checked out. Please check back in a few minutes."
        redirect_to root_url and return
      end
    end
    @offer.reload
    if @offer.available? && @offer.current?
      order = @offer.build_order(product_id: @offer.product_id)
      order.save
      @offer.on_hold!
      @offer.update(start_time: DateTime.now)
      @offer.reload
      Turbo::StreamsChannel.broadcast_update_to("home", target: "buy_button", partial:"offers/buy_button", locals:{offer: @offer})
      scc= StripeCheckoutsService.new
      scc.create_session(order.id)
      order.reload
      redirect_to scc.checkout_session_url(order.checkout_session), allow_other_host: true
    end
  end

  def checkout_success
    checkout_session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @order = Order.find_by(id: checkout_session.client_reference_id)
    checkout_details = StripeCheckoutsService.new.retrieve_completed_checkout_details(params[:session_id])
    if checkout_details.empty?
      redirect_to root_url and return
    end
    if @order.complete(checkout_details)
      self.create
    end
  end

  def cancel_checkout
    checkout_session = Stripe::Checkout::Session.retrieve(params[:session_id])
    order = Order.find_by(checkout_session: params[:session_id])
    if (order!=nil && order.status==nil)
      StripeCheckoutsService.new.expire_session(order.checkout_session)
      @offer=order.offer
      @offer.available!
      order.delete
      flash[:alert]="Checkout session cancelled"
    end
    Turbo::StreamsChannel.broadcast_update_to("home", target: "buy_button", partial:"offers/buy_button", locals:{offer: @offer})
      redirect_to root_url
  end

  def release_hold(offer_id)
    offer = Offer.find(offer_id)
    StripeCheckoutsService.new.expire_session(offer.order.checkout_session)
    offer.order.delete
    offer.available!
  end

end
