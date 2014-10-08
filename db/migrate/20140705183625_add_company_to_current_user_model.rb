class AddCompanyToCurrentUserModel < ActiveRecord::Migration
  	def change
  		change_column_default :photos, :name, ""
  		add_column :activities, :photo_id, :integer
  	end
end
