class ModifyUserByAddingGhostSettings < ActiveRecord::Migration
 	def change
  		change_column :users, :active, :boolean, default: false
  		change_column :users, :email, :string, null: nil
  		change_column :users, :encrypted_password, :string, null: nil
  		change_column :users, :sign_in_count, :integer, null: nil
  	end
end
