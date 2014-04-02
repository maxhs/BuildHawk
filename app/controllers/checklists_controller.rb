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
		@project = Project.find params[:project_id] if params[:project_id]
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
		
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			if current_user.uber_admin?
				redirect_to core_checklists_uber_admin_index_path
			else
				redirect_to checklists_admin_index_path
			end
		end
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
		else
			@subcategory.update_attribute :milestone_date, nil
		end

		if params[:subcategory][:completed_date].present?
			datetime = Date.strptime(params[:subcategory][:completed_date].to_s,"%m/%d/%Y").to_datetime + 12.hours
			@subcategory.update_attribute :completed_date, datetime
		else
			@subcategory.update_attribute :completed_date, nil
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

	def destroy_subcategory
		@subcategory = Subcategory.find params[:subcategory_id]
		@checklist = Checklist.find params[:id]
		@project = @checklist.project
		if @subcategory.destroy && request.xhr?
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
	
	def order_categories
		@checklist = Checklist.find params[:id]
		@project = @checklist.project unless @checklist.project.nil?
		params[:phase].each_with_index do |p,i|
			@phase = Category.find p
			@phase.update_attribute :order_index, i
		end
		respond_to do |format|
			format.js  { render :template => "checklists/reorder"}
		end
	end

	def order_subcategories
		@category = Category.find params[:id]
		@project = @category.checklist.project unless @category.checklist.project.nil?
		params[:subcategory].each_with_index do |p,i|
			subcategory = Subcategory.find p
			subcategory.update_attribute :order_index, i
		end
		respond_to do |format|
			format.js  { render :template => "checklists/reorder"}
		end 
	end

	def order_items
		subcategory = Subcategory.find params[:id]
		@project = subcategory.category.checklist.project
		params[:item].each_with_index do |item,i|
			@item = ChecklistItem.find item
			#why am I using item index here? I don't know.
			@item.update_attribute :item_index, i
		end
		respond_to do |format|
			format.js { render :template => "checklists/reorder"}
		end
	end

	def destroy
		list = Checklist.find params[:id]
		@checklist_id = params[:id] if list
		@core = true if list.core
		list.destroy
		
		@checklist = Checklist.new
		if @core
			@checklists = Checklist.where(:core => true)
			if request.xhr?
				respond_to do |format|
					format.js
				end
			else
				redirect to core_checklists_uber_admin_index_path
			end
		else
			@company = Company.find params[:company_id]
			@checklists = @company.checklists
			if request.xhr?
				respond_to do |format|
					format.js
				end
			else
				render :checklists
			end
		end
		
	end
end
