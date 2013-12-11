class Api::V1::PunchlistsController < Api::V1::ApiController

    def show
    	project = Project.find params[:id]
    	@punchlist = project.punchlists.first
    	respond_to do |format|
        	format.json { render_for_api :punchlist, :json => @punchlist, :root => :punchlist}
      	end
    end

end
