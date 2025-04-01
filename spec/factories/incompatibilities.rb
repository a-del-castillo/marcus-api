FactoryBot.define do
    factory :incompatibility do
      association :part_1, factory: :part
      association :part_2, factory: :part
      description { "These parts are incompatible" }
    end
end
