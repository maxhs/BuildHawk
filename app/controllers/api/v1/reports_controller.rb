class Api::V1::ReportsController < Api::V1::ApiController

    def update
    	@item = PunchlistItem.find params[:id]
    	@item.update_attributes params[:punchlist_item]
    	respond_to do |format|
        	format.json { render_for_api :punchlist, :json => item, :root => :punchlist_item}
      	end
    end

    def show
    	project = Project.find params[:id]
    	reports = project.reports
    	respond_to do |format|
        	format.json { render_for_api :projects, :json => reports, :root => :reports}
      	end
    end

end
