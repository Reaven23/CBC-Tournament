class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :teams do |t|
      t.references :pool, null: false, foreign_key: true
      t.string :name
      t.string :color
      t.text :description

      t.timestamps
    end
  end
end
