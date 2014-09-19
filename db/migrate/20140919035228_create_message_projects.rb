class CreateMessageProjects < ActiveRecord::Migration
  def change
    create_table :message_projects do |t|
    	t.belongs_to :message
    	t.belongs_to :project
      	t.timestamps
    end

    remove_column :messages, :target_project_id, :integer
    #rename_table :task_assignees, :task_users
  end
end
