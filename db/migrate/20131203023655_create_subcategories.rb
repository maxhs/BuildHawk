class CreateSubcategories < ActiveRecord::Migration
  def change
    create_table :subcategories do |t|
      t.belongs_to :category
      t.string :name
      t.integer :order_index
      t.integer :checklist_items_count
      t.datetime :completed_date
      t.datetime :milestone_date
      t.timestamps
    end
  end
end
