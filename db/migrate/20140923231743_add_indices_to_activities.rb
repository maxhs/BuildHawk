class AddIndicesToActivities < ActiveRecord::Migration
  	def change
  		add_index :activities, [:user_id, :project_id, :report_id, :task_id, :comment_id, :checklist_item_id, :message_id], name: "activities_idxs"
  		add_index :messages, [:author_id, :company_id], name: "messages_idx"
  		add_index :message_users, [:user_id, :message_id], name: "message_users_idx"
  		add_index :phases, :core_checklist_id, name: "phase_core_checklist_idx"
  		add_index :reminders, [:user_id, :checklist_item_id, :task_id, :project_id], name: "reminders_idx"
  		add_index :report_topics, [:report_id, :safety_topic_id], name: "report_topics_idx"
  		add_index :tasks, [:tasklist_id, :user_id, :completed_by_user_id], name: "tasks_idx"
  		add_index :tasklists, :project_id, name: "taskslists_idx"
  		add_index :billing_days, [:project_user_id, :company_id], name: "billing_days_idx"
  		add_index :alternates, :user_id, name: "alternates_idx"
  		add_index :photos, :folder_id, name: "photos_folder_idx"
  		remove_column :safety_topics, :report_id, :integer
  		#remove_column :checklist_items, :user_id, :integer
  	end
end
