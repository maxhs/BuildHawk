class AddCompanyToCurrentUserModel < ActiveRecord::Migration
  	def change
  		add_column :connect_users, :company_id, :integer
  		add_column :connect_users, :company_name, :string
  	end
end
