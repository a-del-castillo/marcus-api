class CreatePriceModifiers < ActiveRecord::Migration[8.0]
  def change
    create_table :price_modifiers do |t|
      t.string :main_part
      t.string :variator_part
      t.decimal :price

      t.timestamps
    end
  end
end
