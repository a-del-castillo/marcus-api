class AddOrderToConfigs < ActiveRecord::Migration[8.0]
  def change
    add_column :configs, :order, :integer
  end
end
