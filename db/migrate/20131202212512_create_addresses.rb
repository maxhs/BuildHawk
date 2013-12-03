class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
    	t.belongs_to :user
    	t.belongs_to :project
    	t.belongs_to :company
    	
    	t.boolean :active
    	t.string :street1, :default => ""
    	t.string :street2, :default => ""
    	t.string :city, :default => ""
    	t.string :phone_number, :default => ""
    	t.string :zip, :default => ""
    	t.string :country
    	t.float :latitude
    	t.float :longitude
      	t.timestamps
    end
  end
end
