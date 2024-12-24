class CreateNotificationReceipts < ActiveRecord::Migration[7.0]
  def change
    create_table :notification_receipts do |t|
      t.references :notification, foreign_key: true, null: false
      t.string :receipt_number, null: false
      t.string :status
      t.datetime :sent_at
      t.string :response_code
      t.text :response_message

      t.timestamps
    end
  end
end
