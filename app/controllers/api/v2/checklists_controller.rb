class Api::V2::ChecklistsController < Api::V2::ApiController

    def show
    	project = Project.find params[:id]
    	@checklist = project.checklist
    	respond_to do |format|
        	format.json { render_for_api :checklists, :json => @checklist, :root => :checklist}
      	end
    end

end
