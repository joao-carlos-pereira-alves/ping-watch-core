class AddPermissionsToPlans < ActiveRecord::Migration[7.0]
  def change
    add_column :plans, :monitor_sites, :boolean, default: true
    add_column :plans, :notifications, :boolean, default: true
    add_column :plans, :max_sites, :integer, default: 0
    add_column :plans, :ping_interval, :integer, default: 15
    add_column :plans, :detailed_reports, :boolean, default: false
    add_column :plans, :priority_support, :boolean, default: false
  end
end
