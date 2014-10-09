class AddAttributes < ActiveRecord::Migration
  def change
  	add_column :projects, :checklist_id, :integer
  	add_column :tasks, :completed, :boolean, :default => false
  	add_column :tasks, :completed_at, :datetime
  	add_column :photos, :report_id, :integer
  	add_column :photos, :task_id, :integer
  	add_column :photos, :checklist_item_id, :integer
  end
end
