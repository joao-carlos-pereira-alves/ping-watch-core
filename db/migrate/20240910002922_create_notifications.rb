class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.references :user, foreign_key: true, null: false
      t.integer :alert_type, default: 0, null: false
      t.string :threshold_value, null: true
      t.integer :frequency, default: 0
      t.boolean :enabled, default: true, null: false
      t.integer :notification_method, default: 0
      t.string :uuid
      t.datetime :last_notified_at, null: true

      t.timestamps
    end
  end
end
