class CreateUsedPromos < ActiveRecord::Migration
  	def change
    	create_table :used_promos do |t|
    		t.references :user
    		t.references :promo
      		t.references :company
      		t.timestamps
    	end
  	end
end
