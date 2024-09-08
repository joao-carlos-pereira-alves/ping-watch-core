class CreateSites < ActiveRecord::Migration[7.0]
  def change
    create_table :sites do |t|
      t.references :user
      t.string :url
      t.integer :status, default: 0
      t.string :uuid, default: SecureRandom.uuid

      t.timestamps
    end
  end
end
