FactoryBot.define do
  factory :order do
    association :user
    status { "pending" }
    price { 100.0 }
  end
end