class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :orders, id: :uuid do |t|
      t.integer :status, default: 0
      t.timestamps
    end

    create_table :order_items, id: :uuid do |t|
      t.string :name
      t.integer :quantity
      t.decimal :unit_price, precision: 10, scale: 2
      t.decimal :total, precision: 12, scale: 2, generated_always_as: 'quantity * unit_price', stored: true

      t.references :order, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
