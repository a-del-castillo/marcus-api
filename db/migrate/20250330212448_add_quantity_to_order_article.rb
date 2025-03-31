class AddQuantityToOrderArticle < ActiveRecord::Migration[8.0]
  def change
    add_column :order_articles, :quantity, :integer, default: 1
  end
end
