class ChangeArchivedToHiddenForProjects < ActiveRecord::Migration
  	def change
  		rename_column :projects, :archived, :hidden
  		rename_column :project_users, :archived, :hidden
  	end
end
