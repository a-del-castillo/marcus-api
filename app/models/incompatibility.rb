class Incompatibility < ApplicationRecord
    validates :part_1, :part_2, presence: true
    belongs_to :part_1, class_name: 'Part', foreign_key: 'part_1'
    belongs_to :part_2, class_name: 'Part', foreign_key: 'part_2'
end
