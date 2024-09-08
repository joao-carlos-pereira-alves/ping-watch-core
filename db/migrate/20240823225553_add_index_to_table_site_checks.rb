class AddIndexToTableSiteChecks < ActiveRecord::Migration[7.0]
  def change
    add_index :site_checks, [:site_id, :response_time_ms]
  end
end
