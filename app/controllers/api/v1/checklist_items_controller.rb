class Api::V1::ChecklistItemsController < Api::V1::ApiController

    def update
    	@item = ChecklistItem.find params[:id]
    	@item.update_attributes params[:checklist_item]
    	respond_to do |format|
        	format.json { render_for_api :projects, :json => projects, :root => :projects}
      	end
    end

    def show
    	project = Project.find params[:id]
    	@checklist = project.checklist
    	respond_to do |format|
        	format.json { render_for_api :checklist, :json => @checklist, :root => :checklist}
      	end
    end

end
