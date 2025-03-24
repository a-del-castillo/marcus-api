class CreateIncompatibilities < ActiveRecord::Migration[8.0]
  def change
    create_table :incompatibilities do |t|
      t.string :part_1
      t.string :part_2
      t.string :description

      t.timestamps
    end
  end
end
