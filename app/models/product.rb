class Product < ApplicationRecord
  has_one_attached :image
  has_many :orders
  has_many :offers

  def increment_number_sold
    increment!(:number_sold, touch: true)
  end
end
