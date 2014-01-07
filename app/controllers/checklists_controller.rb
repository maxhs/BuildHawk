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

	def update
		puts "checklist update params: #{params}"
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
		if params[:project_id].present?
			@project = Project.find params[:project_id]
			if request.xhr?
				respond_to do |format|
					format.js { render :template => "projects/checklist" }
				end
			else
				render :checklist
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
		if params[:project_id].present?
			@project = Project.find params[:project_id]
			if request.xhr?
				respond_to do |format|
					format.js { render :template => "projects/checklist" }
				end
			else
				render :checklist
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
	
end
