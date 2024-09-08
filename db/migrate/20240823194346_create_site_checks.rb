class CreateSiteChecks < ActiveRecord::Migration[7.0]
  def change
    create_table :site_checks do |t|
      t.references :site, null: false, foreign_key: true
      t.integer :check_status, null: false
      t.integer :response_time_ms

      t.timestamps
    end
  end
end
