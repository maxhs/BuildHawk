class ChecklistItemsController < ApplicationController
	before_filter :authenticate_user!
	def edit
		@item = ChecklistItem.find params[:id]	
		@checklist = @item.category.phase.checklist
		@project = @checklist.project
		@projects = @project.company.projects if @project
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
		@checklist = @checklist_item.category.phase.checklist
		if @checklist.core && @checklist.company_id.nil?
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
		@category = Category.find params[:category_id]
		@phase = @category.phase
		@checklist = @phase.checklist
		@phase_name = @phase.name
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :new
		end
	end

	def create
		@item = ChecklistItem.create params[:checklist_item]
		@item.move_to_bottom
		@checklist = @item.checklist
		@category = @item.category
		@project = @checklist.project if @checklist.project
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

	def export
		item = ChecklistItem.find params[:id]
		project = item.checklist.project
		params[:names].each do |r|
			puts "r: #{r}"
			recipient = User.where(:full_name => r).first
			recipient = Sub.where(:name => r).first unless recipient
			ChecklistMailer.export(recipient.email, item, project).deliver
		end
		params[:email].split(',').each do |e|
			ChecklistMailer.export(e, item, project).deliver
		end

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render checklist_project_path(project)
		end
	end


	def destroy
		checklist_item = ChecklistItem.find params[:id]
		@item_id = params[:id]
		@category = checklist_item.category
		@checklist = @category.phase.checklist
		@project = @checklist.project
		checklist_item.destroy
		if @project
			render "projects/checklist"
		else
			render "admin/editor"
		end
	end
end
