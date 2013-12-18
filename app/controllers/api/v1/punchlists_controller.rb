class Api::V1::PunchlistsController < Api::V1::ApiController

    def show
    	project = Project.find params[:id]
    	if project.punchlists && project.punchlists.count > 0
    		@punchlist = project.punchlists.first
    	else 
    		project.punchlists.create
    	end
    	respond_to do |format|
        	format.json { render_for_api :punchlist, :json => @punchlist, :root => :punchlist}
      	end
    end

end
