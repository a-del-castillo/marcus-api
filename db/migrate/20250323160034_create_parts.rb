class CreateParts < ActiveRecord::Migration[8.0]
  def change
    create_table :parts do |t|
      t.string :name
      t.string :category
      t.decimal :price
      t.binary :available
      t.integer :incompatible_with, array: true, default: []
      t.json :extra_props

      t.timestamps
    end
  end
end
