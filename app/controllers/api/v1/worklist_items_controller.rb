class Api::V1::WorklistItemsController < Api::V1::ApiController
    before_filter :refactor

    def update
    	@worklist_item = worklistItem.find params[:id]

        params[:worklist_item].delete(:id)

        if params[:worklist_item][:user_assignee].present? 
            user = User.where(:full_name => params[:worklist_item][:user_assignee]).first
            #@worklist_item.update_attributes :assignee_id => user.id, :sub_assignee_id => nil
            params[:worklist_item][:assignee_id] = user.id
            params[:worklist_item][:sub_assignee_id] = nil
            params[:worklist_item].delete(:user_assignee)
        elsif params[:worklist_item][:sub_assignee].present?
            sub = Sub.where(:name => params[:worklist_item][:sub_assignee], :company_id => @worklist_item.worklist.project.company.id).first_or_create
            #@worklist_item.update_attributes :sub_assignee_id => sub.id, :assignee_id => nil
            params[:worklist_item][:assignee_id] = nil
            params[:worklist_item][:sub_assignee_id] = sub.id
            params[:worklist_item].delete(:sub_assignee)
        else
            params[:worklist_item][:assignee_id] = nil
            params[:worklist_item][:sub_assignee_id] = nil
           # @worklist_item.update_attributes :assignee_id => nil, :sub_assignee_id => nil 
        end
        
        if params[:worklist_item][:status].present?
            if params[:worklist_item][:status] == "Completed"
                params[:worklist_item][:completed] = true
                params[:worklist_item][:completed_at] = Time.now
                #@worklist_item.update_attributes :completed => true, :completed_at => Time.now
            else
                params[:worklist_item][:completed] = false
                params[:worklist_item][:completed_at] = nil
                params[:worklist_item][:completed_by_user_id] = nil
                #@worklist_item.update_attributes :completed => false, :completed_at => nil
            end
            params[:worklist_item].delete(:status)
        end
        unless params[:worklist_item][:location].present?
            params[:worklist_item][:location] = nil
            #@worklist_item.update_attribute :location, nil
        end

    	@worklist_item.update_attributes params[:worklist_item]
        
    	respond_to do |format|
        	format.json { render_for_api :worklist, :json => @worklist_item, :root => @root}
      	end
    end

    def create
        @project = Project.find params[:project_id]

        if params[:worklist_item][:user_assignee].present? 
            assignee = User.where(:full_name => params[:worklist_item][:user_assignee]).first
            params[:worklist_item].delete(:user_assignee)
        elsif params[:worklist_item][:sub_assignee].present?
            sub = Sub.where(:name => params[:worklist_item][:sub_assignee]).first_or_create
            params[:worklist_item].delete(:sub_assignee)
        end
        
        @worklist_item = @project.worklists.last.worklist_items.create params[:worklist_item]
        @worklist_item.update_attribute :mobile, true
        
        if assignee
            @worklist_item.update_attribute :assignee_id, assignee.id
        elsif sub
            @worklist_item.update_attribute :sub_assignee_id, sub.id
        end

        if @worklist_item.save
            respond_to do |format|
                format.json { render_for_api :worklist, :json => @worklist_item, :root => @root}
            end
        end
    end

    def photo
        @worklist_item = worklistItem.find params[:id]
        photo = @worklist_item.photos.create params[:photo]
        photo.update_attribute :mobile, true
        respond_to do |format|
            format.json { render_for_api :worklist, :json => @worklist_item, :root => @root}
        end
    end

    private

    def refactor
        ##api compatibility
        if params[:punchlist_item]
            params[:worklist_item] = params[:punchlist_item]
            @root = :punchlist_item
        else
            @root = :worklist_item
        end
        ###
    end
end
