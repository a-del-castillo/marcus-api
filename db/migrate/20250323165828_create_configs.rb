class CreateConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :configs do |t|
      t.string :name
      t.integer :parts, array: true, default: []

      t.timestamps
    end
  end
end
