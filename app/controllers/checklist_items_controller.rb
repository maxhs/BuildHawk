class ChecklistItemsController < ApplicationController
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
		@project = @checklist.project
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			redirect_to checklist_project_path(@project)
		end
	end
end
