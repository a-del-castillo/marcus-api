FactoryBot.define do
    factory :user do
        user_id { SecureRandom.uuid }
        sequence(:username) { |n| "user#{n}" }
        password { "password123" }
        role { "user" }
    end
  end