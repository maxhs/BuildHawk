class Api::V3::TasklistsController < Api::V3::ApiController

    def index
        project = Project.find params[:project_id]
        if project.tasklists && project.tasklists.count > 0
            tasklist = project.tasklists.first
        else 
            tasklist = project.tasklists.create
        end
        respond_to do |format|
            format.json { render_for_api :tasklist, :json => tasklist, :root => :tasklist}
        end
    end

    def show
        project = Project.find params[:id]
    	if project.tasklists && project.tasklists.count > 0
    		tasklist = project.tasklists.first
    	else 
    		tasklist = project.tasklists.create
    	end
    	respond_to do |format|
        	format.json { render_for_api :tasklist, :json => tasklist, :root => :tasklist}
      	end
    end
end