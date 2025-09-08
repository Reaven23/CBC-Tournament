class AddTournamentIdToTeams < ActiveRecord::Migration[7.1]
  def change
    add_reference :teams, :tournament, null: false, foreign_key: true
  end
end
