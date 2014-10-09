class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.references :phase
      t.string :name
      t.integer :order_index
      t.integer :checklist_items_count
      t.datetime :completed_date
      t.datetime :milestone_date
      t.integer :state
      t.timestamps
    end
  end
end
