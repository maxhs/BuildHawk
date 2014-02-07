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
end
