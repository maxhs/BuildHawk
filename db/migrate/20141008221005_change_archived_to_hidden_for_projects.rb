class ChangeArchivedToHiddenForProjects < ActiveRecord::Migration
  	def change
  		change_column :projects, :archived, :hidden
  		change_column :project_users, :archived, :hidden
  	end
end
