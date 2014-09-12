class Api::V3::WorklistItemsController < Api::V3::ApiController
    
    def update
    	task = WorklistItem.find params[:id]
        
        notify = false
        if params[:worklist_item][:assignee_id]
            assignee = User.where(:id => params[:worklist_item][:assignee_id]).first
            notify = true unless task.assignee_id == assignee.id
            params[:worklist_item][:connect_assignee_id] = nil
            params[:worklist_item][:sub_assignee_id] = nil
        # elsif params[:worklist_item][:connect_assignee_id]
        #     connect_user = ConnectUser.where(:id => params[:worklist_item][:connect_assignee_id]).first
        #     notify = true unless task.connect_assignee_id == connect_user.id
        #     params[:worklist_item][:assignee_id] = nil
        #     params[:worklist_item][:sub_assignee_id] = nil
        else
            params[:worklist_item][:assignee_id] = nil
            params[:worklist_item][:sub_assignee_id] = nil
            #params[:worklist_item][:connect_assignee_id] = nil
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

    	task.update_attributes params[:worklist_item]

        if notify
            # if connect_user        
            #     connect_user.text_task(task) if connect_user.phone && connect_user.phone.length > 0
            #     connect_user.email_task(task) if connect_user.email && connect_user.email.length > 0
            # els
            if assignee
                assignee.text_task(task) if assignee.text_permissions && assignee.phone && assignee.phone.length > 0
                assignee.email_task(task) if assignee.email_permissions && assignee.email && assignee.email.length > 0
            end
        end
        
        if params[:user_id]
            current_user = User.find params[:user_id]
            task.log_activity(current_user)
        end
        
    	respond_to do |format|
        	format.json { render_for_api :worklist, :json => task, :root => :task}
      	end
    end

    def create
        project = Project.find params[:project_id]

        ## remove in 1.05
        if params[:worklist_item][:user_assignee].present? 
            assignee = User.where(:full_name => params[:worklist_item][:user_assignee]).first
            params[:worklist_item][:assignee_id] = assignee.id
            params[:worklist_item].delete(:user_assignee)
        elsif params[:worklist_item][:sub_assignee].present?
            sub = Sub.where(:name => params[:worklist_item][:sub_assignee]).first_or_create
            params[:worklist_item][:sub_assignee_id] = sub.id
            params[:worklist_item].delete(:sub_assignee)
        end
        ###

        params[:worklist_item][:mobile] = true
        
        worklist_item = project.worklists.last.worklist_items.create params[:worklist_item]
        worklist_item.activities.create(
            :worklist_item_id => worklist_item.id,
            :project_id => project.id,
            :user_id => worklist_item.user.id,
            :body => "#{worklist_item.user.full_name} created this item.",
            :activity_type => worklist_item.class.name
        )
        
        ### remove in 1.05
        if assignee
            worklist_item.update_attribute :assignee_id, assignee.id
        elsif sub
            worklist_item.update_attribute :sub_assignee_id, sub.id
        end
        ###

        if worklist_item.save
            respond_to do |format|
                format.json { render_for_api :worklist, :json => worklist_item, :root => :task}
            end
        end
    end

    def show
        worklist_item = WorklistItem.find params[:id]
        respond_to do |format|
            format.json { render_for_api :details, :json => worklist_item, :root => :task}
        end
    end

    def photo
        puts "task photo params: #{params}"
        task = Task.where(id: params[:id]).first
        ## android ##
        if params[:file]
            photo = task.photos.new(image: params[:file])
            if params[:file].original_filename
                photo.name = params[:file].original_filename
                photo.save
            end
            params[:photo][:mobile] = true
            photo.update_attributes params[:photo]
        else
        ## ios ##
            photo = task.photos.create params[:photo]
        end

        respond_to do |format|
            format.json { render_for_api :worklist, :json => task, :root => :task}
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

end
