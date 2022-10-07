class Order < ApplicationRecord
  belongs_to :product
  validates :product_id, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :address_street, presence: true
  validates :address_city, presence: true
  validates :address_state, presence: true
  validates :address_zip, presence: true
  validates :email, presence: true
  validates :phone_number, presence: true
  validates :product_id, presence: true
end
