class CreateChecklistItems < ActiveRecord::Migration
  	def change
    	create_table :checklist_items do |t|
	    	t.integer :state
	    	t.string :item_type
	    	t.text :body
	    	t.integer :order_index
	    	t.integer :item_index
	    	t.belongs_to :phase
	    	t.belongs_to :category
	    	t.belongs_to :checklist
	    	t.references :user
	    	t.belongs_to :completed_by_user
	    	t.datetime :critical_date
      		t.datetime :milestone_date
      		t.datetime :completed_date
	      	t.timestamps
    	end

    	add_index :checklist_items, :category_id, :name => 'checklist_item_category_id_ix'
  		add_index :checklist_items, :phase_id, :name => 'checklist_item_phase_id_ix'
  		add_index :checklist_items, :checklist_id, :name => 'checklist_item_checklist_id_ix'
  	end
end
