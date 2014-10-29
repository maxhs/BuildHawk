class Api::V3::PhasesController < Api::V3::ApiController

    def show
    	phase = Phase.find params[:id]
    	respond_to do |format|
        	format.json { render_for_api :v3_checklists, :json => phase, :root => :phase}
      	end
    end

end