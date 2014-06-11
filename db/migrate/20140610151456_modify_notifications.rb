class ModifyNotifications < ActiveRecord::Migration
  	def change
  		add_column :reminders, :active, :boolean, default: true
  		add_index :notifications, :user_id, name: "user_id_idx"
  		add_index :notifications, :checklist_item_id, name: "checklist_item_id_idx"
  		add_index :notifications, :report_id, name: "report_id_idx"
  		add_index :notifications, :comment_id, name: "comment_id_idx"
  		add_index :notifications, :worklist_item_id, name: "worklist_item_id_idx"
  		add_index :notifications, :project_id, name: "project_id_idx"
  	end
end
