class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.string :email
      t.text :message
      t.string :notification_type

      t.timestamps
    end
  end
end
