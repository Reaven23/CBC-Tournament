class AddGameStartAndCourtNumberToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :game_start, :datetime
    add_column :games, :court_number, :string
  end
end
