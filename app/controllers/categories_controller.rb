class CategoriesController < ApplicationController
	before_filter :authenticate_user!

	def new
		@phase = Phase.find params[:phase_id]
		@checklist = @phase.checklist
		@category = @phase.categories.new
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render "admin/editor"
		end
	end

	def create 
		@category = Category.create params[:category]
		@category.move_to_bottom
		@checklist = @category.phase.checklist
		@project = @checklist.project
		@projects = @project.company.projects if @checklist.project
	end

	def edit
		@category = Category.find params[:id]
		if params[:project_id]
			@project = Project.find params[:project_id]
			@projects = @project.company.projects
		end

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			unless @projects
				render "admin/editor"
			end
		end
	end
end
