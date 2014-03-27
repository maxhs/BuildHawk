class ChecklistsController < ApplicationController
	before_filter :authenticate_user!
	def index
		@checklists = current_user.company.checklists
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :index
		end
	end

	def show
		@checklist = Checklist.find params[:id]
	end

	def new
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :new
		end
	end

	def create

	end

	def load_items
		@category = Category.find params[:id]
		@project = @category.checklist.project
		@subcategories = @category.subcategories
		if request.xhr?
			respond_to do |format|
				format.js
			end
		end
	end

	def update
		@checklist = Checklist.find params[:id]
		@checklist.update_attributes params[:checklist]
		@company = current_user.company
		@checklists = @company.checklists
		redirect_to checklists_admin_index_path
		# if request.xhr?
		# 	respond_to do |format|
		# 		format.js { render :template => "admin/checklists"}
		# 	end
		# else
		# 	render 'admin/checklists'
		# end
	end

	def new_checklist_item
		@checklist_item = ChecklistItem.new
		@item_index = params[:item_index]
		@subcategory = Subcategory.find params[:subcategory_id]
		@category = @subcategory.category
		@checklist = @category.checklist
		@category_name = @category.name
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :new_checklist_item
		end
	end

	def create_checklist_item
		index = params[:checklist_item][:item_index]
		@item = ChecklistItem.create params[:checklist_item]
		@subcategory = @item.subcategory
		@checklist = @item.checklist

		if request.xhr?
			respond_to do |format|
				format.js {render template:"admin/create_checklist_item"} 
			end
		else
			render "admin/editor"
		end
	end

	def subcategory
		@subcategory = Subcategory.find params[:subcategory_id]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :subcategory
		end
	end

	def update_subcategory
		@subcategory = Subcategory.find params[:subcategory_id]
		if params[:subcategory][:milestone_date].present?
			datetime = Date.strptime(params[:subcategory][:milestone_date].to_s,"%m/%d/%Y").to_datetime + 12.hours
			@subcategory.update_attribute :milestone_date, datetime
		end
		if params[:subcategory][:name].present?
			@subcategory.update_attribute :name, params[:subcategory][:name]
		end

		@checklist = @subcategory.category.checklist
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

	def category
		@category = Category.find params[:category_id]
		@project = Project.find params[:project_id] if params[:project_id]
		@projects = @project.company.projects 
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :category
		end
	end

	def update_category
		@category = Category.find params[:category_id]
		if params[:category][:milestone_date].present?
			datetime = Date.strptime(params[:category][:milestone_date].to_s,"%m/%d/%Y").to_datetime + 12.hours
			@category.update_attribute :milestone_date, datetime
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

	def destroy_category
		@category = Category.find params[:category_id]
		@checklist = Checklist.find params[:id]
		@project = @checklist.project
		if @category.destroy && request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/checklist"}
			end
		else
			redirect_to checklist_project_path(@project)
		end
	end

	def destroy_subcategory
		@subcategory = Subcategory.find params[:subcategory_id]
		@checklist = Checklist.find params[:id]
		@project = @checklist.project
		if @subcategory.destroy && request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/checklist"}
			end
		else
			redirect_to checklist_project_path(@project)
		end
	end
	
end
