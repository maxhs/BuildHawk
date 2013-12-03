class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
    	t.string :name, :null => false, :default => ""
    	t.string :email
    	t.string :phone_number
    	t.integer :projects_count
      	t.timestamps
    end
  end
end
