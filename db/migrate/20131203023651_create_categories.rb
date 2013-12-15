class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
 	  t.integer :order_index
 	  t.belongs_to :checklist
 	  t.belongs_to :core_checklist
 	  t.datetime :completed_date
      t.datetime :milestone_date
      t.integer :checklist_items_count
      t.integer :subcategories_count
      t.string :name
      t.timestamps
    end
  end
end
