class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
    	t.belongs_to :report
    	t.belongs_to :user
    	t.belongs_to :checklist_item
    	t.belongs_to :worklist_item
    	t.belongs_to :project
    	t.text :body
    	t.boolean :hidden, default: false
      	t.timestamps
    end
  end
end
