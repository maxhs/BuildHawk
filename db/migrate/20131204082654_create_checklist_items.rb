class CreateChecklistItems < ActiveRecord::Migration
  	def change
    	create_table :checklist_items do |t|
	    	t.boolean :complete, :default => false
	    	t.string :status
	    	t.string :item_type
	    	t.text :body
	    	t.integer :order_index
	    	t.integer :item_index
	    	t.belongs_to :subcategory
	    	t.belongs_to :category
	    	t.belongs_to :checklist
	    	t.belongs_to :completed_by_user
	    	t.datetime :critical_date
      		t.datetime :milestone_date
      		t.datetime :completed_date
	      	t.timestamps
    	end

    	add_index :checklist_items, :category_id, :name => 'checklist_item_category_id_ix'
  		add_index :checklist_items, :subcategory_id, :name => 'checklist_item_subcategory_id_ix'
  		add_index :checklist_items, :checklist_id, :name => 'checklist_item_checklist_id_ix'
  	end
end
