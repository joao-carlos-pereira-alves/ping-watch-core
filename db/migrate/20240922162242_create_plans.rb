class CreatePlans < ActiveRecord::Migration[7.0]
  def change
    create_table :plans do |t|
      t.integer :name
      t.decimal :price
      t.text :features

      t.timestamps
    end
  end
end
