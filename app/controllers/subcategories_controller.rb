class SubcategoriesController < ApplicationController
	before_filter :authenticate_user!

	def new
		@category = Category.find params[:category_id]
		@checklist = @category.checklist
		@subcategory = @category.subcategories.new
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render "admin/editor"
		end
	end

	def create 
		@subcategory = Subcategory.create params[:subcategory]
		@subcategory.move_to_top
		@checklist = @subcategory.category.checklist
		@project = @checklist.project if @checklist.project
	end

	def edit
		@subcategory = Subcategory.find params[:id]
		if params[:project_id]
			@project = Project.find params[:project_id]
			@projects = @project.company.projects
		end
	end
end
