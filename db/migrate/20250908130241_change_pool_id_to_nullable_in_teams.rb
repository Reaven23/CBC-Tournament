class ChangePoolIdToNullableInTeams < ActiveRecord::Migration[7.1]
  def change
    change_column_null :teams, :pool_id, true
  end
end
