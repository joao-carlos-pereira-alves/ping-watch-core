class AddNotificationReceiptsCountColumnToNotification < ActiveRecord::Migration[7.0]
  def change
    add_column :notifications, :notification_receipts_count, :integer, default: 0
    add_column :notification_receipts, :notification_method, :integer, default: 0
  end
end
