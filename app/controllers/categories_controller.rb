class CategoriesController < ApplicationController

	def new
		@checklist = Checklist.find params[:id]
		@category = @checklist.categories.new
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render "admin/editor"
		end
	end

	def show
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
			render :category
		end
	end

	def update
		@category = Category.find params[:id]
		if params[:category][:milestone_date].present?
			datetime = Date.strptime(params[:category][:milestone_date].to_s,"%m/%d/%Y").to_datetime + 12.hours
			@category.update_attribute :milestone_date, datetime
		else
			@category.update_attribute :milestone_date, nil
		end
		
		if params[:category][:completed_date].present?
			datetime = Date.strptime(params[:category][:completed_date].to_s,"%m/%d/%Y").to_datetime + 12.hours
			@category.update_attribute :completed_date, datetime
		else
			@category.update_attribute :completed_date, nil
		end
		
		if params[:category][:name].present?
			@category.update_attribute :name, params[:category][:name]
		end

		@checklist = @category.checklist
		unless @checklist.project.nil?
			@project = @checklist.project
			@projects = @checklist.project.company.projects
			if request.xhr?
			 	respond_to do |format|
			 		format.js { render :template => "projects/checklist" }
			 	end
			else
			 	redirect_to checklist_project_path(@project)
			end
		else 
			if request.xhr?
				respond_to do |format|
					format.js { render :template => "admin/editor" }
				end
			else
				render "admin/editor"
			end
		end
	end

	def destroy
		@category = Category.find params[:id]
		@checklist = Checklist.find params[:checklist_id]
		@project = @checklist.project
		if @category.destroy && request.xhr?
			if @project
				respond_to do |format|
					format.js { render :template => "projects/checklist"}
				end
			else
				respond_to do |format|
					format.js { render :template => "admin/editor"}
				end
			end
		else
			if @project
				redirect_to checklist_project_path(@project)
			else 
				render "admin/editor"
			end
		end
	end
end
