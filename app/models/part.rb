class Part < ApplicationRecord
    has_many :incompatibilities
    has_many :incompatibilities_as_part_1, class_name: "Incompatibility", foreign_key: "part_1"
    has_many :incompatibilities_as_part_2, class_name: "Incompatibility", foreign_key: "part_2"
    has_many :pricemodifiers_as_main_part, class_name: "PriceModifier", foreign_key: "main_part"

    has_many :order_articles
    has_many :orders, through: :order_articles

    def pricemodifiers
        pricemodifiers_as_main_part
    end

    def incompatibilities
        incompatibilities_as_part_1.or(incompatibilities_as_part_2)
    end

    def as_json(options = {})
        super(options).merge(quantity: order_articles.find_by(order_id: options[:order_id])&.quantity || 0)
    end
end
