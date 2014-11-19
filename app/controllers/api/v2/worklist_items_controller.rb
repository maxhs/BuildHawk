class Api::V2::WorklistItemsController < Api::V2::ApiController
    before_filter :refactor_punchlist

    def update
    	task = Task.find params[:id]
        
        notify = false
        ## to remove in 1.05
        if params[:worklist_item][:user_assignee]
            user = User.where(:full_name => params[:worklist_item][:user_assignee]).first
            params[:worklist_item][:assignee_ids] = [user.id] if user
            params[:worklist_item].delete(:user_assignee)
        elsif params[:worklist_item][:sub_assignee]
            params[:worklist_item].delete(:sub_assignee)
        ###
        elsif params[:worklist_item][:assignee_id]
            assignee = User.where(:id => params[:worklist_item][:assignee_id]).first
            params[:worklist_item][:assignee_ids] = [assignee.id]
            notify = true if assignee && task.assignee_id != assignee.id
        else
            params[:worklist_item][:assignee_ids] = nil
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

        params[:worklist_item].delete(:connect_assignee_id) if params[:worklist_item][:connect_assignee_id]
        params[:worklist_item].delete(:assignee_id) if params[:worklist_item][:assignee_id]

    	task.update_attributes params[:worklist_item]

        if notify
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
        	format.json { render_for_api :tasklist, :json => task, :root => @root}
      	end
    end

    def create
        project = Project.find params[:project_id]

        params[:worklist_item].delete(:connect_assignee_id) if params[:worklist_item][:connect_assignee_id]

        ## remove in 1.05
        if params[:worklist_item][:user_assignee].present? 
            assignee = User.where(:full_name => params[:worklist_item][:user_assignee]).first
            params[:worklist_item][:assignee_id] = assignee.id
            params[:worklist_item].delete(:user_assignee)
        elsif params[:worklist_item][:sub_assignee].present?
            params[:worklist_item].delete(:sub_assignee)
        end
        ###

        params[:worklist_item][:mobile] = true
        
        task = project.tasklists.last.tasks.create params[:worklist_item]
        task.activities.create(
            :task_id => task.id,
            :project_id => project.id,
            :user_id => task.user.id,
            :body => "#{task.user.full_name} created this item.",
            :activity_type => task.class.name
        )
    
        if task.save
            respond_to do |format|
                format.json { render_for_api :tasklist, :json => task, :root => @root}
            end
        end
    end

    def show
        task = Task.find params[:id]
        respond_to do |format|
            format.json { render_for_api :details, :json => task, :root => @root}
        end
    end

    def photo
        params[:photo][:task_id] = params[:id] if params[:id]
        if params[:photo][:worklist_item_id]
            params[:photo][:task_id] = params[:photo][:worklist_item_id]
            params[:photo].delete(:worklist_item_id)
        end
        params[:photo][:source] = "Tasklist"

        ## android ##
        if params[:file]
            photo = Photo.new(image: params[:file])
            if params[:file].original_filename
                photo.name = params[:file].original_filename
                photo.save
            end
            params[:photo][:mobile] = true
            photo.update_attributes params[:photo]
            respond_to do |format|
                format.json { render_for_api :tasklist, :json => photo.task, :root => @root}
            end
        else
        ## ios ##
            photo = Photo.create params[:photo]
            respond_to do |format|
                format.json { render_for_api :tasklist, :json => photo.task, :root => @root}
            end
        end

    end

    def destroy
        item = Task.find params[:id]
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
