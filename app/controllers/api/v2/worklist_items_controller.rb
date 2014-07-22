class Api::V2::WorklistItemsController < Api::V2::ApiController
    before_filter :refactor_punchlist

    def update
    	worklist_item = WorklistItem.find params[:id]
        params[:worklist_item].delete(:id)

        ## to remove in 1.05
        if params[:worklist_item][:user_assignee].present? 
            user = User.where(:full_name => params[:worklist_item][:user_assignee]).first
            params[:worklist_item][:assignee_id] = user.id
            params[:worklist_item][:sub_assignee_id] = nil
            params[:worklist_item].delete(:user_assignee)
        elsif params[:worklist_item][:sub_assignee].present?
            sub = Sub.where(:name => params[:worklist_item][:sub_assignee], :company_id => worklist_item.worklist.project.company.id).first_or_create
            params[:worklist_item][:assignee_id] = nil
            params[:worklist_item][:connect_assignee_id] = nil
            params[:worklist_item][:sub_assignee_id] = sub.id
            params[:worklist_item].delete(:sub_assignee)
        ###
        elsif params[:worklist_item][:assignee_id]
            @notify_user = true
            params[:worklist_item][:connect_assignee_id] = nil
            params[:worklist_item][:sub_assignee_id] = nil
        elsif params[:worklist_item][:connect_assignee_id]
            @notify_connect = true
            params[:worklist_item][:assignee_id] = nil
            params[:worklist_item][:sub_assignee_id] = nil
        else
            params[:worklist_item][:assignee_id] = nil
            params[:worklist_item][:sub_assignee_id] = nil
            params[:worklist_item][:connect_assignee_id] = nil
        end
        
        if params[:worklist_item][:completed] == "1"
            params[:worklist_item][:completed] = true
            params[:worklist_item][:completed_at] = Time.now
        else
            params[:worklist_item][:completed] = false
            params[:worklist_item][:completed_at] = nil
            params[:worklist_item][:completed_by_user_id] = nil
        end

        unless params[:worklist_item][:location].present?
            params[:worklist_item][:location] = nil
        end

    	task = worklist_item.update_attributes params[:worklist_item]
        
        if @notify_connect
            connect_user = ConnectUser.where(:id => params[:worklist_item][:connect_assignee_id]).first
            if connect_user
                connect_user.text_task(task) if connect_user.phone && connect_user.phone.length
                connect_user.email_task(task) if connect_user.email && connect_user.email.length
            end
        elsif @notify_user
            user = User.where(:id => params[:worklist_item][:assignee_id]).first
            if user
                user.text_task(task) if user.text_permissions && user.phone && connect_user.phone.length
                user.email_task(task) if user.email_permissions && user.email && connect_user.email.length
            end
        end
        
        if params[:user_id]
            current_user = User.find params[:user_id]
            worklist_item.notify(current_user)
        end
        
    	respond_to do |format|
        	format.json { render_for_api :worklist, :json => worklist_item, :root => @root}
      	end
    end

    def create
        project = Project.find params[:project_id]

        if params[:worklist_item][:user_assignee].present? 
            assignee = User.where(:full_name => params[:worklist_item][:user_assignee]).first
            params[:worklist_item].delete(:user_assignee)
        elsif params[:worklist_item][:sub_assignee].present?
            sub = Sub.where(:name => params[:worklist_item][:sub_assignee]).first_or_create
            params[:worklist_item].delete(:sub_assignee)
        end
        params[:worklist_item][:mobile] = true
        
        worklist_item = project.worklists.last.worklist_items.create params[:worklist_item]
        worklist_item.activities.create(
            :worklist_item_id => worklist_item.id,
            :project_id => project.id,
            :user_id => worklist_item.user.id,
            :body => "#{worklist_item.user.full_name} created this item.",
            :activity_type => worklist_item.class.name
        )
        
        if assignee
            worklist_item.update_attribute :assignee_id, assignee.id
        elsif sub
            worklist_item.update_attribute :sub_assignee_id, sub.id
        end

        if worklist_item.save
            respond_to do |format|
                format.json { render_for_api :worklist, :json => worklist_item, :root => @root}
            end
        end
    end

    def show
        worklist_item = WorklistItem.find params[:id]
        respond_to do |format|
            format.json { render_for_api :details, :json => worklist_item, :root => @root}
        end
    end

    def photo
        params[:photo][:worklist_item_id] = params[:id] if params[:id]

        ## android ##
        if params[:file]
            photo = Photo.new(image: params[:file])
            if params[:file].original_filename
                photo.name = params[:file].original_filename
                photo.save
            end
            params[:photo][:mobile] = true
            photo.update_attributes params[:photo]
        else
        ## ios ##
            photo = Photo.create params[:photo]
        end

        respond_to do |format|
            format.json { render_for_api :worklist, :json => photo.worklist_item, :root => @root}
        end
    end

    def destroy
        item = WorklistItem.find params[:id]
        if item.destroy
            render json: {success: true}
        else
            render json: {failure: true}
        end
    end

    private

    def refactor_punchlist
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
