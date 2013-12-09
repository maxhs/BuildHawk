class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
    	t.string :name, :null => false, :default => ""
    	t.string :email
    	t.string :phone_number
    	t.boolean :pre_register
    	t.string :contact_name
    	t.integer :projects_count
      	t.timestamps
    end
  end
end
