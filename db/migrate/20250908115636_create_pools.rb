class CreatePools < ActiveRecord::Migration[7.1]
  def change
    create_table :pools do |t|
      t.references :tournament, null: false, foreign_key: true
      t.string :name
      t.integer :position

      t.timestamps
    end
  end
end
