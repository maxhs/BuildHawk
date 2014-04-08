class CreateArchivedProjects < ActiveRecord::Migration
  def change
    create_table :archived_projects do |t|
    	t.belongs_to :user
      	t.belongs_to :project
      	t.timestamps
    end
    add_column :photos, :description, :text
    add_column :project_users, :archived, :boolean, default: false
    add_column :project_users, :core, :boolean, default: false
    add_column :project_users, :project_group_id, :integer
  end
end
