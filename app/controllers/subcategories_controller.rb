class SubcategoriesController < ApplicationController

	def edit
		@subcategory = Subcategory.find params[:id]
		@project = Project.find params[:project_id] if params[:project_id]
		@projects = @project.company.projects
	end
end
