class ModifyCompanyModel < ActiveRecord::Migration
  def change
  	add_column :companies, :active, :boolean
  	add_column :report_users, :connect_user_id, :integer
  	add_column :project_users, :connect_user_id, :integer
  	#remove_column :connect_users, :worklist_item_id, :integer
  	#remove_column :connect_users, :checklist_item_id, :integer
  	#remove_column :connect_users, :report_id, :integer
  	add_column :worklist_items, :connect_assignee_id, :integer
  	rename_table :apn_registrations, :push_tokens
  	add_column :push_tokens, :device_type, :integer
  end
end
