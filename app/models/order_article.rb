class OrderArticle < ApplicationRecord
    belongs_to :order, foreign_key: 'order_id'
    belongs_to :part, foreign_key: 'part_id', optional: true
    belongs_to :config, foreign_key: 'config_id', optional: true

    validates :part_id, presence: true, if: -> { config_id.nil? }
    validates :config_id, presence: true, if: -> { part_id.nil? }
end
