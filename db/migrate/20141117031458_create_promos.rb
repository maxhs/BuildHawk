class CreatePromos < ActiveRecord::Migration
  	def change
    	create_table :promos do |t|
    		t.decimal :amount, precision: 8, scale: 2
    		t.float :percentage
    		t.string :name
    		t.references :company
    		t.references :user
      		t.timestamps
    	end
  	end
end
