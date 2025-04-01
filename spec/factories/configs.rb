FactoryBot.define do
  factory :config do
    sequence(:name) { |n| "Configuration #{n}" }
    price { 100.0 }
    association :user
    
    transient do
      parts_count { 0 }
    end
    
    after(:create) do |config, evaluator|
      if evaluator.parts_count > 0
        parts = create_list(:part, evaluator.parts_count)
        config.parts = parts
      else
        config.parts = []
      end
    end
  end
end

