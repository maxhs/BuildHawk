class Api::V1::PunchlistItemsController < Api::V1::ApiController

    def update
    	@punchlist_item = PunchlistItem.find params[:id]
        if params[:punchlist_item][:user_assignee].present? 
            user = User.where(:full_name => params[:punchlist_item][:user_assignee]).first
            @punchlist_item.update_attributes :assignee_id => user.id, :sub_assignee_id => nil
        elsif params[:punchlist_item][:sub_assignee].present?
            sub = Sub.where(:name => params[:punchlist_item][:sub_assignee], :company_id => @punchlist_item.punchlist.project.company.id).first_or_create
            @punchlist_item.update_attributes :sub_assignee_id => sub.id, :assignee_id => nil
        else @punchlist_item.assignee_id != nil || @punchlist_item.sub_assignee_id != nil
            @punchlist_item.update_attributes :assignee_id => nil, :sub_assignee_id => nil 
        end

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

        if params[:punchlist_item][:user_assignee].present? 
            user = User.where(:full_name => params[:punchlist_item][:user_assignee]).first
            params[:punchlist_item].delete(:user_assignee)
        elsif params[:punchlist_item][:sub_assignee].present?
            sub = Sub.where(:name => params[:punchlist_item][:sub_assignee]).first_or_create
            params[:punchlist_item].delete(:sub_assignee)
        end
        puts "params after deleting: #{params}"
        @punchlist_item = @project.punchlists.last.punchlist_items.create params[:punchlist_item]
        
        if user
            @punchlist_item.update_attribute :assignee_id, user.id
            puts "assignee is a user: #{user.full_name}"
        elsif sub
            @punchlist_item.update_attribute :assignee_id, sub.id
            puts "assignee is a sub: #{sub.name}"
        end

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
