class AddMobileIdToPhotoObject < ActiveRecord::Migration
  	def change
  		add_column :photos, :taken_at, :datetime
  		add_column :users, :mobile_token, :string
  	end
end
