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
      add_column :reminders, :checklist_id, :integer
      add_column :reminders, :phase_id, :integer
      add_column :reminders, :category_id, :integer
  	end
end
