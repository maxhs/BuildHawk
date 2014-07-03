class Api::V2::ChecklistItemsController < Api::V2::ApiController

    def update
    	item = ChecklistItem.find params[:id]
    	item.update_attributes params[:checklist_item]
        if params[:user_id]
            user = User.find params[:user_id]
            if item.status.length
                item.activities.create(
                    :body => "#{user.full_name} updated the status for this item to \"#{status}\".",
                    :project_id => item.checklist.project.id,
                    :activity_type => item.class.name
                )
            end
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
