class CreateUsedPromos < ActiveRecord::Migration
  	def change
    	create_table :used_promos do |t|
    		t.references :user
    		t.references :promo
      		t.references :company
      		t.timestamps
    	end

    	add_column :company_subs, :email, :string
    	add_column :company_subs, :phone, :string
    	add_column :company_subs, :contact_name, :string
      add_column :checklists, :flagged_for_removal, :boolean
  	end
end
