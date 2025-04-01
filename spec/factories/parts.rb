FactoryBot.define do
  factory :part do
    sequence(:name) { |n| "Part #{n}" }
    category { "Category" }
    price { 100.0 }
    available { true }
  end
end