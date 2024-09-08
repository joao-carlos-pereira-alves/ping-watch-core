class AddHostnameToTableSite < ActiveRecord::Migration[7.0]
  def change
    add_column :sites, :hostname, :string
  end
end
