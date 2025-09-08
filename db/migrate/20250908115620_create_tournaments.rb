class CreateTournaments < ActiveRecord::Migration[7.1]
  def change
    create_table :tournaments do |t|
      t.string :name
      t.text :description
      t.date :start_date
      t.date :end_date
      t.string :status
      t.integer :max_teams
      t.boolean :has_third_place
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
