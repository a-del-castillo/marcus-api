FactoryBot.define do
  factory :order_article do
    association :order
    association :part
    association :config
    quantity { 1 }
  end
end