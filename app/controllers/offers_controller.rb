class OffersController < ApplicationController

  skip_before_action :verify_authenticity_token

  def create
    product = Product.order(:updated_at).first
    @offer = product.offers.build(status:"available", current: "true")
    @offer.save
    Turbo::StreamsChannel.broadcast_update_to("home", target: "current_offer", partial:"offers/offer", locals:{offer: @offer})
    Turbo::StreamsChannel.broadcast_update_to("home", target: "buy_button", partial:"offers/buy_button", locals:{offer: @offer})
  end

  def home
    @offer=Offer.where(current: true).last
  end

  def accept
    @offer = Offer.find(params[:offer_id])
    if @offer.eligible_for_checkout?
      checkout_url = @offer.create_checkout
      Turbo::StreamsChannel.broadcast_update_to("home", target: "buy_button", partial:"offers/buy_button", locals:{offer: @offer})
      redirect_to checkout_url, allow_other_host: true
    elsif @offer.current==false || @offer.accepted?
      flash[:alert] = "The item you selected is no longer available"
      redirect_to root_url and return
    else
      flash[:alert] = "The item you selected is in the process of being checked out. Please check back in a few minutes."
      redirect_to root_url and return
    end
  end

  def checkout_success
    @order = Order.find_by(checkout_session: params[:session_id])
    checkout_details = StripeCheckoutsService.new.retrieve_completed_checkout_details(params[:session_id])
    if checkout_details.empty?
      redirect_to root_url and return
    end
    if @order.complete(checkout_details)
      self.create
    end
  end

  def cancel_checkout
    order = Order.find_by(checkout_session: params[:session_id])
    if (order!=nil && order.status==nil)
      @offer = order.offer
      @offer.release_hold
      Turbo::StreamsChannel.broadcast_update_to("home", target: "buy_button", partial:"offers/buy_button", locals:{offer: @offer})
    end
    redirect_to root_url
  end


end
