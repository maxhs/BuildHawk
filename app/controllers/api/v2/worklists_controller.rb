class Api::V2::WorklistsController < Api::V2::ApiController

    def index
        project = Project.find params[:project_id]
        if project.tasklists && project.tasklists.count > 0
            worklist = project.tasklists.first
        else 
            worklist = project.tasklists.create
        end
        respond_to do |format|
            format.json { render_for_api :tasklist, :json => worklist, :root => :punchlist}
        end
    end

    def show
        project = Project.find params[:id]
    	if project.tasklists && project.tasklists.count > 0
    		worklist = project.tasklists.first
    	else 
    		worklist = project.tasklists.create
    	end
    	respond_to do |format|
        	format.json { render_for_api :tasklist, :json => worklist, :root => :punchlist}
      	end
    end
end