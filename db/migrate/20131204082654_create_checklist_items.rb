class CreateChecklistItems < ActiveRecord::Migration
  	def change
    	create_table :checklist_items do |t|
	    	t.boolean :complete, :default => false
	    	t.string :status
	    	t.string :item_type
	    	t.text :body
	    	t.belongs_to :subcategory
	    	t.datetime :critical_date
      		t.datetime :milestone_date
	      	t.timestamps
    	end
  	end
end
