class CreateOrderArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :order_articles do |t|
      t.integer :order_id
      t.integer :part_id
      t.integer :config_id

      t.timestamps
    end
  end
end
