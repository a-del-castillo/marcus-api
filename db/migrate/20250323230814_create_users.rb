class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :user_id
      t.string :username
      t.string :password_digest
      t.string :about

      t.timestamps
    end
  end
end
