class Api::V2::ChecklistItemsController < Api::V2::ApiController

    def update
    	item = ChecklistItem.find params[:id]
        
        if params[:checklist_item]
            
            ## API compatibility
            if params[:checklist_item][:status]
                if params[:checklist_item][:status] == "Completed"
                    params[:checklist_item][:state] = 1
                elsif params[:checklist_item][:status] == "In-Progress"
                    params[:checklist_item][:state] = 0
                elsif params[:checklist_item][:status] == "Not Applicable"
                    params[:checklist_item][:state] = -1
                end
            end
            ##
            
            params[:checklist_item][:state] = nil unless params[:checklist_item][:state].present?
            item.update_attributes params[:checklist_item]
        else
            item.update_attribute :state, nil
        end

        if params[:user_id]
            user = User.find params[:user_id]
            item.log_activity(user)
        else
            item.log_activity(nil)
        end

    	respond_to do |format|
        	format.json { render_for_api :details, :json => item, :root => :checklist_item}
      	end
    end

    def show
    	item = ChecklistItem.find params[:id]
        respond_to do |format|
            format.json { render_for_api :details, :json => item, :root => :checklist_item}
        end
    end

    def photo
        params[:photo][:checklist_item_id] = params[:id] if params[:id]
        photo = Photo.create params[:photo]
        item = ChecklistItem.find params[:photo][:checklist_item_id]
        photo.update_attributes :mobile => true, :phase => item.category.phase.name
        respond_to do |format|
            format.json { render_for_api :details, :json => photo.checklist_item, :root => :checklist_item}
        end
    end

end
