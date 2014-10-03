class DestroyConnectUserAndActiveRecordDelayedJob < ActiveRecord::Migration
  	def change
  		remove_column :report_users, :connect_user_id, :integer
  		remove_column :task_users, :connect_user_id, :integer
  		remove_column :tasks, :connect_assignee_id, :integer
  		#drop_table :connect_users
  		#drop_table :delayed_jobs
  	end
end
