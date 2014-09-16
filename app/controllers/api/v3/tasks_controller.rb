class Api::V3::TasksController < Api::V3::ApiController
    
    def update
    	task = Task.find params[:id]
        
        notify = false
        if params[:task][:assignee_id]
            assignee = User.where(:id => params[:task][:assignee_id]).first
            notify = true unless task.assignee_id == assignee.id
            params[:task][:connect_assignee_id] = nil
            params[:task][:sub_assignee_id] = nil
        # elsif params[:worklist_item][:connect_assignee_id]
        #     connect_user = ConnectUser.where(:id => params[:worklist_item][:connect_assignee_id]).first
        #     notify = true unless task.connect_assignee_id == connect_user.id
        #     params[:worklist_item][:assignee_id] = nil
        #     params[:worklist_item][:sub_assignee_id] = nil
        else
            params[:task][:assignee_id] = nil
            params[:task][:sub_assignee_id] = nil
            #params[:worklist_item][:connect_assignee_id] = nil
        end
        
        if params[:task][:completed] == "1"
            params[:task][:completed] = true
            params[:task][:completed_at] = Time.now
        else
            params[:task][:completed] = false
            params[:task][:completed_at] = nil
            params[:task][:completed_by_user_id] = nil
        end

        unless params[:task][:location].present?
            params[:task][:location] = nil
        end

    	task.update_attributes params[:task]

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

        # ## remove in 1.05
        # if params[:worklist_item][:user_assignee].present? 
        #     assignee = User.where(:full_name => params[:worklist_item][:user_assignee]).first
        #     params[:worklist_item][:assignee_id] = assignee.id
        #     params[:worklist_item].delete(:user_assignee)
        # elsif params[:worklist_item][:sub_assignee].present?
        #     sub = Sub.where(:name => params[:worklist_item][:sub_assignee]).first_or_create
        #     params[:worklist_item][:sub_assignee_id] = sub.id
        #     params[:worklist_item].delete(:sub_assignee)
        # end
        # ###

        params[:task][:mobile] = true
        
        task = project.tasklists.last.tasks.create params[:task]
        task.activities.create(
            :task_id => task.id,
            :project_id => project.id,
            :user_id => task.user.id,
            :body => "#{task.user.full_name} created this item.",
            :activity_type => task.class.name
        )
        
        ### remove in 1.05
        if assignee
            task.update_attribute :assignee_id, assignee.id
        elsif sub
            task.update_attribute :sub_assignee_id, sub.id
        end
        ###

        if task.save
            respond_to do |format|
                format.json { render_for_api :worklist, :json => task, :root => :task}
            end
        end
    end

    def show
        task = Task.find params[:id]
        respond_to do |format|
            format.json { render_for_api :details, :json => task, :root => :task}
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

end
