class AddAttributes < ActiveRecord::Migration
  def change
  	add_column :projects, :checklist_id, :integer
  	add_column :punchlist_items, :assignee_id, :integer
  	add_column :punchlist_items, :completed, :boolean, :default => false
  	add_column :punchlist_items, :completed_at, :datetime
  	add_column :photos, :report_id, :integer
  	add_column :photos, :punchlist_item_id, :integer
  	add_column :photos, :checklist_item_id, :integer
  end
end
