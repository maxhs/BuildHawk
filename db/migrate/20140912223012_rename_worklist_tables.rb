class RenameWorklistTables < ActiveRecord::Migration
  	def change
  		remove_column :worklists, :worklist, :boolean
  		rename_column :worklist_items, :worklist_id, :tasklist_id
  		rename_column :activities, :worklist_item_id, :task_id
  		rename_column :comments, :worklist_item_id, :task_id
  		rename_column :notifications, :worklist_item_id, :task_id
  		rename_column :photos, :worklist_item_id, :task_id
  		rename_column :reminders, :worklist_item_id, :task_id
  		rename_column :subs, :worklist_item_id, :task_id
  		rename_column :task_assignees, :worklist_item_id, :task_id
  		remove_index :notifications, name:"worklist_item_id_idx"
  		rename_table :worklists, :tasklists
  		rename_table :worklist_items, :tasks
  	end
end
