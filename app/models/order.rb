class Order < ApplicationRecord
  belongs_to :offer

  def complete(order_details)
    if status.nil?
      update!(
        name: order_details[:name],
        address_line1: order_details[:address_line1],
        address_line2: order_details[:address_line2],
        address_city: order_details[:address_city],
        address_state: order_details[:address_state],
        address_zip: order_details[:address_zip],
        email: order_details[:email],
        phone_number: order_details[:phone_number],
        status: order_details[:status]
      )
      offer.complete
      return true
    end
    false
  end
end
