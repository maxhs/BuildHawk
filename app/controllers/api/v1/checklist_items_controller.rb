class Api::V1::ChecklistItemsController < Api::V1::ApiController

    def update
    	item = ChecklistItem.find params[:id]
    	item.update_attribute :status, params[:checklist_item][:status]
    	respond_to do |format|
        	format.json { render_for_api :checklist, :json => item, :root => :checklist_item}
      	end
    end

    def show
    	item = ChecklistItem.find params[:id]
        respond_to do |format|
            format.json { render_for_api :detail, :json => item, :root => :checklist_item}
        end
    end

    def photo
        @checklist_item = ChecklistItem.find params[:id]
        @checklist_item.photos.create params[:photo]
        respond_to do |format|
            format.json { render_for_api :checklist, :json => @checklist_item, :root => :checklist_item}
        end
    end

end
