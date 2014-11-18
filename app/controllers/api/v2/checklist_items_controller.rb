class Api::V2::ChecklistItemsController < Api::V2::ApiController

    def update
    	item = ChecklistItem.find params[:id]
        if params[:checklist_item] && params[:checklist_item][:state].to_i != item.state
            should_log_activity = true
            if params[:checklist_item][:state] == 1
                params[:checklist_item][:completed_by_user_id] = params[:user_id] if params[:user_id]
            end
        else
            should_log_activity = false
        end

        if params[:checklist_item]
            
            ## API compatibility
            params[:checklist_item].delete(:completed)
            params[:checklist_item].delete(:id)
            if params[:checklist_item][:status]
                if params[:checklist_item][:status] == "Completed"
                    params[:checklist_item][:state] = 1
                elsif params[:checklist_item][:status] == "In-Progress"
                    params[:checklist_item][:state] = 0
                elsif params[:checklist_item][:status] == "Not Applicable"
                    params[:checklist_item][:state] = -1
                end
                params[:checklist_item].delete(:status)
            end
            ##
            
            unless params[:checklist_item][:state]
                params[:checklist_item][:state] = nil
                params[:checklist_item][:completed_date] = nil
                params[:checklist_item][:completed_by_user_id] = nil
            end
            item.update_attributes params[:checklist_item]
        else
            item.update_attribute :state, nil
        end

        if should_log_activity
            if params[:user_id]
                user = User.where(:id => params[:user_id]).first
                item.log_activity(user) if user
            else
                item.log_activity(nil)
            end
        end

    	respond_to do |format|
        	format.json { render_for_api :checklist_item, :json => item, :root => :checklist_item}
      	end
    end

    def show
    	item = ChecklistItem.find params[:id]
        respond_to do |format|
            format.json { render_for_api :checklist_item, :json => item, :root => :checklist_item}
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
