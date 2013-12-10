class ChecklistItemsController < ApplicationController
	def update
		puts "should be updating a checklist item"
		@checklist_item = ChecklistItem.find params[:id]
		if params[:checklist_item][:critical_date].present?
			datetime = Date.strptime(params[:checklist_item][:critical_date].to_s,"%m/%d/%Y").to_datetime + 12.hours
			@checklist_item.update_attribute :critical_date, datetime
			params[:checklist_item].delete(:critical_date)
		end
		@checklist_item.update_attributes params[:checklist_item]
		if params[:checklist_item][:status] == "Completed"
			puts "should be updating completed by user"
			@checklist_item.update_attribute :completed_by_user_id, current_user.id
		end
		@checklist = @checklist_item.subcategory.category.checklist
		@project = @checklist.project
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :update
		end
	end
end
