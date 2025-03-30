class AddUserToConfigs < ActiveRecord::Migration[8.0]
  def change
    add_column :configs, :user, :integer
  end
end
