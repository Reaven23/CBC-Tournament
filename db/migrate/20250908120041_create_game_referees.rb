class CreateGameReferees < ActiveRecord::Migration[7.1]
  def change
    create_table :game_referees do |t|
      t.references :game, null: false, foreign_key: true
      t.references :referee, null: false, foreign_key: true
      t.string :role

      t.timestamps
    end
  end
end
