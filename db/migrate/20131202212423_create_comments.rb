class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
    	t.belongs_to :user
    	t.belongs_to :report
    	t.integer :punchlist_item_id
    	t.integer :checklist_item_id
    	t.text :body
      	t.timestamps
    end
  end
end
