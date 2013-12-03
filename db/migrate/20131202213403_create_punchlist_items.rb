class CreatePunchlistItems < ActiveRecord::Migration
  def change
    create_table :punchlist_items do |t|
    	t.text :body
    	t.belongs_to :punchlist
    	t.belongs_to :user, :class_name => "User"
    	t.string :location
      	t.timestamps
    end
  end
end
