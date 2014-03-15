class Api::V2::PunchlistItemsController < Api::V2::ApiController

    def update
    	@punchlist_item = PunchlistItem.find params[:id]
        params[:punchlist_item].delete(:id)

        if params[:punchlist_item][:user_assignee].present? 
            user = User.where(:full_name => params[:punchlist_item][:user_assignee]).first
            #@punchlist_item.update_attributes :assignee_id => user.id, :sub_assignee_id => nil
            params[:punchlist_item][:assignee_id] = user.id
            params[:punchlist_item][:sub_assignee_id] = nil
            params[:punchlist_item].delete(:user_assignee)
        elsif params[:punchlist_item][:sub_assignee].present?
            sub = Sub.where(:name => params[:punchlist_item][:sub_assignee], :company_id => @punchlist_item.punchlist.project.company.id).first_or_create
            #@punchlist_item.update_attributes :sub_assignee_id => sub.id, :assignee_id => nil
            params[:punchlist_item][:assignee_id] = nil
            params[:punchlist_item][:sub_assignee_id] = sub.id
            params[:punchlist_item].delete(:sub_assignee)
        else
            params[:punchlist_item][:assignee_id] = nil
            params[:punchlist_item][:sub_assignee_id] = nil
           # @punchlist_item.update_attributes :assignee_id => nil, :sub_assignee_id => nil 
        end
        
        if params[:punchlist_item][:status].present?
            if params[:punchlist_item][:status] == "Completed"
                params[:punchlist_item][:completed] = true
                params[:punchlist_item][:completed_at] = Time.now
                #@punchlist_item.update_attributes :completed => true, :completed_at => Time.now
            else
                params[:punchlist_item][:completed] = false
                params[:punchlist_item][:completed_at] = nil
                params[:punchlist_item][:completed_by_user_id] = nil
                #@punchlist_item.update_attributes :completed => false, :completed_at => nil
            end
            params[:punchlist_item].delete(:status)
        end
        unless params[:punchlist_item][:location].present?
            params[:punchlist_item][:location] = nil
            #@punchlist_item.update_attribute :location, nil
        end

    	@punchlist_item.update_attributes params[:punchlist_item]
        
    	respond_to do |format|
        	format.json { render_for_api :punchlist, :json => @punchlist_item, :root => :punchlist_item}
      	end
    end

    def create
        @project = Project.find params[:project_id]

        if params[:punchlist_item][:user_assignee].present? 
            assignee = User.where(:full_name => params[:punchlist_item][:user_assignee]).first
            params[:punchlist_item].delete(:user_assignee)
        elsif params[:punchlist_item][:sub_assignee].present?
            sub = Sub.where(:name => params[:punchlist_item][:sub_assignee]).first_or_create
            params[:punchlist_item].delete(:sub_assignee)
        end
        
        @punchlist_item = @project.punchlists.last.punchlist_items.create params[:punchlist_item]
        @punchlist_item.update_attribute :mobile, true
        
        if assignee
            @punchlist_item.update_attribute :assignee_id, assignee.id
        elsif sub
            @punchlist_item.update_attribute :sub_assignee_id, sub.id
        end

        if @punchlist_item.save
            respond_to do |format|
                format.json { render_for_api :punchlist, :json => @punchlist_item, :root => :punchlist_item}
            end
        end
    end

    def photo
        @punchlist_item = PunchlistItem.find params[:id]
        photo = @punchlist_item.photos.create params[:photo]
        photo.update_attribute :mobile, true
        respond_to do |format|
            format.json { render_for_api :punchlist, :json => @punchlist_item, :root => :punchlist_item}
        end
    end

end
