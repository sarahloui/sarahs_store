class AddOfferReferenceToOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :offer, foreign_key: true
  end
end
