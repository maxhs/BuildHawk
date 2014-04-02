class SubcategoriesController < ApplicationController

	def edit
		@subcategory = Subcategory.find params[:id]
		if params[:project_id]
			@project = Project.find params[:project_id]
			@projects = @project.company.projects
		end
	end
end
