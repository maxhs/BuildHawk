class Api::V2::PunchlistsController < Api::V2::ApiController

    def show
    	project = Project.find params[:id]
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
