class Api::V3::TasksController < Api::V3::ApiController
    
    def update
    	task = Task.find params[:id]
        
        notify = false
        if params[:task][:assignee_id]
            assignee = User.where(:id => params[:task][:assignee_id]).first
            notify = true if assignee && task.assignee_id != assignee.id
        else
            params[:task][:assignee_id] = nil
        end

        params[:task][:user_ids] = params[:task][:user_ids].split(',') if params[:task][:user_ids]
        
        if params[:task][:completed] == "1"
            params[:task][:completed] = true
            params[:task][:completed_at] = Time.now
        else
            params[:task][:completed] = false
            params[:task][:completed_at] = nil
            params[:task][:completed_by_user_id] = nil
        end

        params[:task][:location] = nil unless params[:task][:location].present?    

    	task.update_attributes params[:task]

        if notify
            assignee.text_task(task) if assignee.text_permissions && assignee.phone && assignee.phone.length > 0
            assignee.email_task(task) if assignee.email_permissions && assignee.email && assignee.email.length > 0
        end
        
        if params[:user_id]
            current_user = User.where(id: params[:user_id]).first
            task.log_activity(current_user) if current_user
        end
        
    	respond_to do |format|
        	format.json { render_for_api :tasklist, :json => task, :root => :task}
      	end
    end

    def create
        project = Project.find params[:project_id]

        params[:task][:user_ids] = params[:task][:user_ids].split(',') if params[:task][:user_ids]
        params[:task][:mobile] = true
        
        task = project.tasklists.last.tasks.create params[:task]
        task.activities.create(
            :task_id => task.id,
            :project_id => project.id,
            :user_id => task.user.id,
            :body => "#{task.user.full_name} created this item.",
            :activity_type => task.class.name
        )
    
        if task.save
            respond_to do |format|
                format.json { render_for_api :tasklist, :json => task, :root => :task}
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
