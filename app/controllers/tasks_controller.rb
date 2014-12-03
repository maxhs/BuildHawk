class TasksController < AppController
	before_filter :find_company
	before_filter :authenticate_user!, :except => [:find_company, :edit]

	def new
		@task = Task.new
		@task.photos.build
		@project = Project.find params[:project_id]
		@tasklist = @project.tasklists.last
		@company = @project.company
		@projects = @company.projects
		@users = @project.users
		@subs = @project.project_subs
		@locations = @tasklist.tasks.collect do |task|
			{id: task.location, 
			text: task.location} if task.location && task.location.length > 0
		end.compact.to_json.gsub('"id"','id').gsub('"text"','text').to_s
		@tasks = @tasklist.tasks
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render template:"projects/tasklist"
		end
	end

	def create
		@project = Project.find params[:project_id]
		if @project.tasklists.count == 0
			@tasklist = @project.tasklists.create
		else
			@tasklist = @project.tasklists.first
		end
		if params[:task][:assignee_attributes].present?
			assignee = User.where(:full_name => params[:task][:assignee_attributes][:full_name]).first
			params[:task].delete(:assignee_attributes)
		end

		@task = @tasklist.tasks.create params[:task]
		@locations = @tasklist.tasks.collect do |task|
			{id: task.location, 
			text: task.location} if task.location && task.location.length > 0
		end.compact.to_json.gsub('"id"','id').gsub('"text"','text').to_s
			
		if assignee
			@task.update_attribute :assignee_id, assignee.id
		end

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			redirect_to tasklist_project_path(@project)
		end
	end

	def show
		
	end

	def edit
		#@locations = @tasklist.tasks.map{|i| i.location if i.location && i.location.length > 0}.compact.flatten.to_json
		@locations = @tasklist.tasks.collect do |task|
				{id: task.location, 
				text: task.location} if task.location && task.location.length > 0
			end.compact.to_json.gsub('"id"','id').gsub('"text"','text').to_s
	rescue
		if @project
			redirect_to tasklist_project_path @project
		else
			redirect_to root_url
		end
	end

	def update
		unless user_signed_in?
			if request.xhr?
				respond_to do |format|
					format.js { render :template => "tasks/login"}
				end
			else 
				redirect_to login_path
			end
		else
			if params[:task][:assignee_attributes].present?
				assignee = User.where(:full_name => params[:task][:assignee_attributes][:full_name]).first
				params[:task].delete(:assignee_attributes)
				if assignee
					params[:task][:assignee_id] = assignee.id 
				else
					params[:task][:assignee_id] = nil 
				end
			end
					
			if params[:task][:completed] == "true"
				params[:task][:completed_by_user_id] = current_user.id
				params[:task][:completed_at] = Time.now
			else
				params[:task][:completed_by_user_id] = nil
				params[:task][:completed_at] = nil
			end
			
			@task.update_attributes params[:task]
			@task.log_activity(current_user)

			if request.xhr?
				respond_to do |format|
					format.js
				end
			else 
				redirect_to tasklist_project_path(@project)
			end
		end
	end
		
	def destroy
		@task_id = @task.id
		@tasklist = @task.tasklist
		if @task && @task.destroy && request.xhr?
			respond_to do |format|
				format.js
			end
		elsif @project
			redirect_to tasklist_project_path(@project)
		else 
			redirect_to root_url
		end
	end

	def export
		@task.export
		redirect_to tasklist_project_path(@project) unless request.xhr?
	end

	def find_company
		@task = Task.where(id: params[:id]).first
		if !user_signed_in?# && (@task.task.project.project_users.include?(current_user) || @task.assignee == current_user)
			redirect_to projects_path
			flash[:notice] = "You don't have access to this task".html_safe
		elsif @task	
			@tasklist = @task.tasklist
			@project = @tasklist.project
			@tasks = @tasklist.tasks
			@company = @project.company
			@projects = @company.projects
			@users = @project.users
			@subs = @project.project_subs
		elsif params[:project_id]
			@project = Project.find params[:project_id]
			@users = @project.users
			@subs = @project.project_subs
		end
	end
end
