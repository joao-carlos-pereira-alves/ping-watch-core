class RemoveUserFromSites < ActiveRecord::Migration[7.0]
  def change
    remove_reference :sites, :user
  end
end
