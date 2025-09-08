class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.references :tournament, null: false, foreign_key: true
      t.references :pool, null: true, foreign_key: true
      t.references :home_team, null: false, foreign_key: { to_table: :teams }
      t.references :away_team, null: false, foreign_key: { to_table: :teams }
      t.references :winner, null: true, foreign_key: { to_table: :teams }
      t.string :type
      t.integer :round_number
      t.datetime :scheduled_at
      t.integer :home_score
      t.integer :away_score
      t.string :status
      t.text :notes

      t.timestamps
    end
  end
end
