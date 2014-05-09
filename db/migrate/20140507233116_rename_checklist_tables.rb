class RenameChecklistTables < ActiveRecord::Migration
  def change
  	rename_table :categories, :phases
  	rename_table :subcategories, :categories
  	rename_column :categories, :category_id, :phase_id
  end
end
