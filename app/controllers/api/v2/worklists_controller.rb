class Api::V2::WorklistsController < Api::V2::ApiController

    def index
        project = Project.find params[:project_id]
        if project.worklists && project.worklists.count > 0
            worklist = project.worklists.first
        else 
            worklist = project.worklists.create
        end
        respond_to do |format|
            format.json { render_for_api :worklist, :json => worklist, :root => :punchlist}
        end
    end

    def show
        project = Project.find params[:id]
    	if project.worklists && project.worklists.count > 0
    		worklist = project.worklists.first
    	else 
    		worklist = project.worklists.create
    	end
    	respond_to do |format|
        	format.json { render_for_api :worklist, :json => worklist, :root => :punchlist}
      	end
    end
end