class CreatePunchlistItems < ActiveRecord::Migration
  def change
    create_table :punchlist_items do |t|
    	t.text :body
    	t.belongs_to :punchlist
    	t.belongs_to :user
    	t.string :location
    	t.integer :order_index
      	t.timestamps
    end
  end
end
