class Api::V1::PunchlistItemsController < Api::V1::ApiController

    def update
    	@punchlist_item = PunchlistItem.find params[:id]
    	@punchlist_item.update_attributes params[:punchlist_item]
        if params[:status].present?
            if params[:status] == "Completed"
                @punchlist_item.update_attributes :completed => true, :completed_at => Time.now
            else
                @punchlist_item.update_attributes :completed => false, :completed_at => nil
            end
        end
    	respond_to do |format|
        	format.json { render_for_api :punchlist, :json => @punchlist_item, :root => :punchlist_item}
      	end
    end

    def create
        @project = Project.find params[:project_id]
        @punchlist_item = @project.punchlists.last.punchlist_items.create params[:punchlist_item]
        if @punchlist_item.save
            respond_to do |format|
                format.json { render_for_api :punchlist, :json => @punchlist_item, :root => :punchlist_item}
            end
        end
    end

    def photo
        @punchlist_item = PunchlistItem.find params[:id]
        @punchlist_item.photos.create params[:photo]
        respond_to do |format|
            format.json { render_for_api :punchlist, :json => @punchlist_item, :root => :punchlist_item}
        end
    end

end
