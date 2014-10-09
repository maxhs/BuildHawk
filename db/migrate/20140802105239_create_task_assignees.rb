class CreateTaskAssignees < ActiveRecord::Migration
  def change
    create_table :task_assignees do |t|
    	t.references :user
    	t.references :task
      	t.timestamps
    end
  end
end
