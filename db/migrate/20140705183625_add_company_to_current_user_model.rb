class AddCompanyToCurrentUserModel < ActiveRecord::Migration
  	def change
  		add_column :connect_users, :company_id, :integer
  	end
end
