class PunchlistItemsController < ApplicationController
	def destroy
		item = PunchlistItem.find params[:id]
		@punchlist = item.punchlist
		@items = @punchlist.punchlist_items
		@project = @punchlist.project
		item.destroy
		if request.xhr?
			respond_to do |format|
				format.js {render template: "projects/worklist"}
			end
		else
			redirect_to worklist_project_path(@project)
		end
	end

	def generate
		@item = PunchlistItem.find params[:id]
		@project = @item.punchlist.project
		if @item.assignee
			@recipient = @item.assignee
			PunchlistItemMailer.punchlist_item(@item,@recipient).deliver
		elsif @item.sub_assignee
			@recipient = @item.sub_assignee
			PunchlistItemMailer.punchlist_item(@item,@recipient).deliver
		end
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to worklist_project_path(@project)
		end
	end
end
