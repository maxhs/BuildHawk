class ConnectController < AppController
	before_filter :authenticate_user!

	def index
		# unless user_signed_in?
		# 	if params[:email]
		# 		current_user = User.where(:email => params[:email]).first
		# 	end
		# end
		
		project = Project.where(:id => params[:project_id]).first if params[:project_id]
		if current_user
			if project
				@tasks = current_user.connect_tasks(project)
			else
				@tasks = current_user.connect_tasks(nil)
			end
			@companies = @tasks.map{|t| t.tasklist.project.company}.uniq
      	end
	    
	end

	def show
		@company = Company.find params[:id]
		@tasks = current_user.connect_tasks(nil).map{|t| t if t.tasklist.project.company.id == @company.id}.compact
	end

	def task
		@task = Task.find params[:id]
		@project = @task.tasklist.project
		@company = @project.company
		@tasks = current_user.connect_tasks(nil).map{|t| t if t.tasklist.project.company.id == @company.id}.compact
		
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :show
		end
	end
end
