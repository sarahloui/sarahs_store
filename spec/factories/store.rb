FactoryBot.define do
  factory :product do
    name { "Dress" }
    description { "Silk dress" }
    price { 7950 }
    number_sold { 0 }
  end

  factory :offer do
    product

    trait :current do
      current { true }
    end

    trait :available do
      status { "available" }
    end

    trait :on_hold do
      status { "on_hold" }
    end

    trait :expired_hold do
      status { "on_hold" }
      start_time { 2.hours.ago }
    end

    trait :valid_hold do
      status { "on_hold" }
      start_time { 1.second.ago }
    end

    factory :current_available_offer, traits: [:current, :available]
    factory :on_hold_offer, traits: [:current, :on_hold]
    factory :offer_with_expired_hold, traits: [:current, :expired_hold]
    factory :offer_with_valid_hold, traits: [:current, :valid_hold]
    factory :on_hold_offer_with_incomplete_order do
      after(:create) do |offer|
        create :incomplete_order, offer: offer
      end
    end
  end

  factory :order do
    offer
    trait :completed do
      status { "paid" }
    end
    trait :incomplete do
      status { nil }
    end

    after(:build) do |order|
      product = order.offer.product
      order.product_id = product.id
    end

    factory :incomplete_order, traits: [:incomplete]
  end
end
