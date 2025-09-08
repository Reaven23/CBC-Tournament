class AddDateToTournaments < ActiveRecord::Migration[7.1]
  def change
    add_column :tournaments, :date, :date
  end
end
