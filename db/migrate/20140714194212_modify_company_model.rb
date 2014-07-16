class ModifyCompanyModel < ActiveRecord::Migration
  def change
  	add_column :companies, :active, :boolean
  	add_column :report_users, :connect_user_id, :integer
  	add_column :project_users, :connect_user_id, :integer
  end
end
