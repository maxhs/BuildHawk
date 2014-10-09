class CreateAlternates < ActiveRecord::Migration
  def change
    create_table :alternates do |t|
      	t.belongs_to :user
      	t.string :email
      	t.string :phone
      	t.timestamps
    end
    rename_column :users, :phone_number, :phone
    rename_column :companies, :phone_number, :phone
    rename_column :addresses, :phone_number, :phone
    rename_column :leads, :phone_number, :phone
    add_column :users, :text_permissions, :boolean, default: true
  end
end
