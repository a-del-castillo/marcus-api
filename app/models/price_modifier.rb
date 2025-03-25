class PriceModifier < ApplicationRecord
    validates :main_part, :variator_part, :price, presence: true
    belongs_to :main_part, class_name: 'Part', foreign_key: 'main_part'
    belongs_to :variator_part, class_name: 'Part', foreign_key: 'variator_part'
end
