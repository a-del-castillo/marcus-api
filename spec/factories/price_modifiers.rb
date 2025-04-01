FactoryBot.define do
    factory :price_modifier do
      association :main_part, factory: :part
      association :variator_part, factory: :part
      price { 150.0 }
    end
end
