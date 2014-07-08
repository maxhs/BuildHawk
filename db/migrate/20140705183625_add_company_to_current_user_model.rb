class AddCompanyToCurrentUserModel < ActiveRecord::Migration
  	def change
  		add_column :connect_users, :company_id, :integer
  		add_column :connect_users, :company_name, :string
  		change_column_default :photos, :name, ""
  		add_column :activities, :photo_id, :integer
  	end
end
