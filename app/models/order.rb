class Order < ApplicationRecord
    has_many :order_articles, foreign_key: 'order_id'
    has_many :parts, through: :order_articles
    has_many :configs, through: :order_articles
    
    accepts_nested_attributes_for :parts
    accepts_nested_attributes_for :configs
end
