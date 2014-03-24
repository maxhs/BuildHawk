class ChecklistItemsController < ApplicationController
	def edit
		@item = ChecklistItem.find params[:id]	
		@core = params[:core] if params[:core].present?
	end

	def update
		@checklist_item = ChecklistItem.find params[:id]
		if params[:checklist_item][:critical_date].present?
			datetime = Date.strptime(params[:checklist_item][:critical_date].to_s,"%m/%d/%Y").to_datetime + 12.hours
			@checklist_item.update_attribute :critical_date, datetime
			params[:checklist_item].delete(:critical_date)
		end
		if params[:checklist_item][:status].present?
			status = params[:checklist_item][:status][1]
			params[:checklist_item].delete(:status)
			if status == "No Status"
				@checklist_item.update_attribute :status, nil
			else 
				@checklist_item.update_attribute :status, status
			end
		end
		@checklist_item.update_attributes params[:checklist_item]
		if status && status == "Completed"
			@checklist_item.update_attribute :completed_by_user_id, current_user.id
		end
		@checklist = @checklist_item.subcategory.category.checklist
		if @checklist.core
			@items = @checklist.items
			if request.xhr?
				respond_to do |format|
					format.js {render :template => "uber_admin/core_checklist"}
				end
			else 
				redirect_to core_checklist_uber_admin_index_path
			end
		elsif @checklist.project_id
			@project = @checklist.project
			if request.xhr?
				respond_to do |format|
					format.js {render :template => "projects/checklist"}
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

	def new
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
			render :new
		end
	end

	def create_item
		index = params[:checklist_item][:item_index]
		@item = ChecklistItem.create params[:checklist_item]
		@checklist = @item.checklist
		@subcategory = @item.subcategory
		if request.xhr?
			respond_to do |format|
				format.js 
			end
		else
			render :checklist
		end
	end

	def show
		@item = ChecklistItem.find params[:id]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :show
		end
	end

	def generate
		@item = ChecklistItem.find params[:id]
	end

	def destroy
		@checklist_item = ChecklistItem.find params[:id]
		@item_id = params[:id]
		@checklist = @checklist_item.checklist
		@project = @checklist_item.subcategory.category.checklist.project
		@checklist_item.destroy
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			redirect_to checklist_project_path(@project)
		end
	end
end
