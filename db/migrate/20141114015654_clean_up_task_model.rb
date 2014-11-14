class CleanUpTaskModel < ActiveRecord::Migration
  	def change
  		remove_column :tasks, :assignee_id, :integer
  		remove_index :tasks, name: "tasks_idx"
  		add_index :tasks, [:tasklist_id, :user_id, :completed_by_user_id], name: "tasks_indexes"
  	end
end
