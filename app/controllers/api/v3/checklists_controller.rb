class Api::V3::ChecklistsController < Api::V3::ApiController

    def index
        project = Project.find params[:project_id]
        @checklist = project.checklist
        respond_to do |format|
            format.json { render_for_api :v3_checklists, :json => @checklist, :root => :checklist}
        end
    end

    def show
    	project = Project.find params[:id]
    	@checklist = project.checklist
    	respond_to do |format|
        	format.json { render_for_api :checklists, :json => @checklist, :root => :checklist}
      	end
    end

end
