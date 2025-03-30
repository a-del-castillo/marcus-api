class AddPriceToConfigs < ActiveRecord::Migration[8.0]
  def change
    add_column :configs, :price, :decimal
  end
end
