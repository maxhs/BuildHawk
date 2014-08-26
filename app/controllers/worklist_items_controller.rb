class WorklistItemsController < AppController
	before_filter :find_company
	before_filter :authenticate_user!, :except => [:find_company, :edit]

	def new
		@task = WorklistItem.new
		@task.photos.build
		@task.build_assignee
		@project = Project.find params[:project_id]
		@worklist = @project.worklists.last
		@company = @project.company
		@projects = @company.projects
		@connect_users = @project.connect_users
		@users = @project.users
		@subs = @project.project_subs
		@locations = @project.worklists.last.worklist_items.map{|i| i.location if i.location && i.location.length > 0}.flatten
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :new
		end
	end

	def create
		@project = Project.find params[:project_id]
		if @project.worklists.count == 0
			@worklist = @project.worklists.create
		else
			@worklist = @project.worklists.first
		end
		if params[:worklist_item][:assignee_attributes].present?
			assignee = User.where(:full_name => params[:worklist_item][:assignee_attributes][:full_name]).first
			sub_assignee = Sub.where(:name => params[:worklist_item][:assignee_attributes][:full_name]).first unless assignee
			params[:worklist_item].delete(:assignee_attributes)
		end

		@task = @worklist.worklist_items.create params[:worklist_item]
		
		if assignee
			@task.update_attribute :assignee_id, assignee.id
		elsif sub_assignee
			@task.update_attribute :sub_assignee_id, sub_assignee.id
		end

		@tasks = @worklist.worklist_items if @worklist
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/worklist"}
			end
		else 
			redirect_to worklist_project_path(@project)
		end
	end

	def show
		@task = WorklistItem.find params[:id]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :show
		end
	end

	def edit
		@locations = @worklist.worklist_items.map{|i| i.location if i.location && i.location.length > 0}.flatten
		@task.build_assignee if @task.assignee.nil?
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :edit
		end
	end

	def update
		unless user_signed_in?
			if request.xhr?
				respond_to do |format|
					format.js { render :template => "worklist_items/login"}
				end
			else 
				redirect_to login_path
			end
		else
			if params[:worklist_item][:assignee_attributes].present?
				assignee = User.where(:full_name => params[:worklist_item][:assignee_attributes][:full_name]).first
				params[:worklist_item].delete(:assignee_attributes)
				if assignee
					params[:worklist_item][:assignee_id] = assignee.id 
				else
					params[:worklist_item][:assignee_id] = nil 
				end
			end

			if params[:worklist_item][:connect_assignee].present?
				connect_assignee = ConnectUser.where(:id => params[:worklist_item][:connect_assignee][:id]).first
				params[:worklist_item].delete(:connect_assignee)
				if connect_assignee
					params[:worklist_item][:connect_assignee_id] = connect_assignee.id 
				else
					params[:worklist_item][:connect_assignee_id] = nil 
				end
			end
					
			if params[:worklist_item][:completed] == "true"
				params[:worklist_item][:completed_by_user_id] = current_user.id
				params[:worklist_item][:completed_at] = Time.now
			else
				params[:worklist_item][:completed_by_user_id] = nil
				params[:worklist_item][:completed_at] = nil
			end
			@task.update_attributes params[:worklist_item]

			@task.activities.create(
				:user_id => current_user.id,
				:body => "#{current_user.full_name} just updated this item",
				:project_id => @task.worklist.project.id,
				:activity_type => @task.class.name
			)
			if request.xhr?
				respond_to do |format|
					format.js
				end
			else 
				redirect_to worklist_project_path(@project)
			end
		end
	end
		
	def destroy
		@task.destroy!
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to worklist_project_path(@project)
		end
	end

	def generate
		if @task.assignee
			@recipient = @task.assignee
			WorklistItemMailer.worklist_item(@task,@recipient).deliver
		elsif @task.sub_assignee
			@recipient = @task.sub_assignee
			WorklistItemMailer.worklist_item(@task,@recipient).deliver
		end
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to worklist_project_path(@project)
		end
	end

	def find_company
		@task = WorklistItem.find params[:id] if params[:id]
		if !user_signed_in?# && (@task.worklist.project.project_users.include?(current_user) || @task.assignee == current_user)
			redirect_to projects_path
			flash[:notice] = "You don't have access to this task".html_safe
		elsif @task	
			@worklist = @task.worklist
			@project = @worklist.project
			@tasks = @worklist.worklist_items
			@company = @project.company
			@projects = @company.projects
			@users = @project.users
			@connect_users = @project.connect_users
			@subs = @project.project_subs
		elsif params[:project_id]
			@project = Project.find params[:project_id]
			@users = @project.users
			@connect_users = @project.connect_users
			@subs = @project.project_subs
		end
	end
end
