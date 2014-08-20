class CreateTaskAssignees < ActiveRecord::Migration
  def change
    create_table :task_assignees do |t|
    	t.belongs_to :user
    	t.belongs_to :connect_user
    	t.belongs_to :worklist_item
      	t.timestamps
    end
  end
end
