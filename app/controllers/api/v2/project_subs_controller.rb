class Api::V2::ProjectSubsController < Api::V2::ApiController

	def create
		project = Project.find params[:project_id]
		name = "#{params[:subcontractor][:name]}"
		subcontractor = Company.where("name ILIKE ?",name).first_or_create
		subcontractor.update_attributes params[:subcontractor] 
		company.company_subs.create :subcontractor_id => subcontractor.id
    	respond_to do |format|
        	format.json { render_for_api :reports, :json => company, :root => :company}
      	end
	end

	def show
		project = Project.find params[:id]
    	respond_to do |format|
        	format.json { render_for_api :projects, :json => project, :root => :project}
      	end
	end

	def add_user
		project = Project.find params[:project_id]
		project_sub = project.project_subs.where(:id => params[:id]).first_or_create
		task = WorklistItem.find params[:task_id] if params[:task_id] && params[:task_id] != 0
		if params[:user][:email]
			user = User.where(:email => params[:user][:email]).first
			if user
				#existing user, notify them by email
			else
				alternate = Alternate.where(:email => params[:user][:email]).first
				user = alternate.user if alternate
			end
		
			if user
				respond_to do |format|
		        	format.json { render_for_api :user, :json => user, :root => :user}
		      	end
			elsif task
				puts "could find user for task assignment: #{params[:user]}"
				connect_user = task.connect_users.create params[:user]
				respond_to do |format|
			       	format.json { render_for_api :user, :json => connect_user, :root => :user}
		      	end
			end
		elsif params[:user][:phone]
			user = User.where(:phone => params[:user][:phone]).first
			if user
				#existing user
				
			else
				alternate = Alternate.where(:phone => params[:user][:phone]).first
				if alternate
					user = alternate.user
					user.text_task(task) if task
				end
			end
		
			if user
				respond_to do |format|
			       	format.json { render_for_api :user, :json => user, :root => :user}
		      	end
			elsif task
				connect_user = task.connect_users.create params[:user]
				connect_user.text_task
				respond_to do |format|
			       	format.json { render_for_api :user, :json => connect_user, :root => :user}
		      	end
			end
		end
	end

end