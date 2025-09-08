class CreateReferees < ActiveRecord::Migration[7.1]
  def change
    create_table :referees do |t|
      t.references :tournament, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone

      t.timestamps
    end
  end
end
