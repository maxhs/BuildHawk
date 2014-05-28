class Api::V2::PunchlistsController < Api::V2::ApiController

    def show
        ## should remove params[:id] component after API compatibility issues are solved
        if params[:project_id].present?
            project = Project.find params[:project_id]
        else
        	project = Project.find params[:id]
        end

    	if project.punchlists && project.punchlists.count > 0
    		punchlist = project.punchlists.first
    	else 
    		punchlist = project.punchlists.create
    	end
    	respond_to do |format|
        	format.json { render_for_api :punchlist, :json => punchlist, :root => :punchlist}
      	end
    end

end
