class Api::V2::ChecklistItemsController < Api::V2::ApiController

    def update
    	item = ChecklistItem.find params[:id]
    	item.update_attribute :status, params[:checklist_item][:status]
    	respond_to do |format|
        	format.json { render_for_api :detail, :json => item, :root => :checklist_item}
      	end
    end

    def show
    	item = ChecklistItem.find params[:id]
        respond_to do |format|
            format.json { render_for_api :detail, :json => item, :root => :checklist_item}
        end
    end

    def photo
        params[:photo][:checklist_item_id] = params[:id] if params[:id]
        photo = Photo.create params[:photo]
        @checklist_item = photo.checklist_item
        photo.update_attributes :mobile => true, :phase => @checklist_item.category.phase.name
        respond_to do |format|
            format.json { render_for_api :detail, :json => photo.checklist_item, :root => :checklist_item}
        end
    end

end
