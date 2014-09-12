class ModifyUsersTableAgain < ActiveRecord::Migration
  def change
  	change_column :users, :active, :boolean, default: false
  	change_column :users, :email, :string, null: true
  	change_column :users, :encrypted_password, :string, null: true
  	change_column :users, :sign_in_count, :integer, null: true, default: 0
  end
end
