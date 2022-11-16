module ProductsHelper
  def formatted_price(price)
    number_to_currency(price/100.00)
  end
end
