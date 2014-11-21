class ProjectsController < AppController
	before_filter :authenticate_user!
	before_filter :fetch
	before_filter :find_project, except: [:new]

	def new
		@users = current_user.company.users
		@subs = current_user.company.company_subs

		if @company.customer_id.nil? && current_user.uber_admin?
			@charges = @company.charges
		  	active_projects = @company.projects.where(active: true).count
		  	@amount = active_projects * 1000 / 100
			redirect_to billing_index_path
		else
			@project = Project.new
			@project.build_address
			@checklists = @user.company.checklists.where(core: true)
		end
	end

	def create
		list = Checklist.where(id: params[:checklist_id]).first
		@project = @company.projects.create params[:project]
		project_user = current_user.project_users.create project_id: @project.id
		@checklist = list.duplicate(@company.id, @project.id) if params[:checklist_id]
		reset_projects

	    @messages = current_user.messages
	    if request.xhr?
	    	respond_to do |format|
	    		format.js
	    	end
	    else
			render :index
		end
	end

	def index
		if params[:company_id]
			@company = Company.find params[:company_id]
		end
		
		@messages = current_user.messages 

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :index
		end
	end

	def show
		if @project.checklist 
			@checklist = @project.checklist
			items = @checklist.checklist_items
			@item_count = items.count
			
			current_time = Time.now
			@upcoming_items = items.select{|i| i.critical_date if i.critical_date && i.critical_date > current_time}.sort_by(&:critical_date).last(5)
		end

		@recent_photos = @project.recent_photos(5)
		@activities = @project.activities.first(5)

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :show
		end
	end

	def edit
		@project = Project.find params[:id]
		if @project.company
			@project_groups = @project.company.project_groups 
			@users = @project.company.users
			@subs = @project.company.company_subs.flatten.sort_by{|cs| cs.subcontractor.name}
		end

		@project.users.build
		unless @project.address
			@project.build_address
		end
		
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :edit
		end
	end

	def update
		if params[:project][:checklist].present?
			checklist = Checklist.find_by(name: params[:project][:checklist])
			params[:project].delete(:checklist)
			params[:project][:checklist] = checklist
		end
		if params[:project][:project_group_id] == "No Assignment"
			params[:project][:project_group_id] = nil
		end
		@project = Project.find params[:id]
		@project.update_attributes params[:project]
		if @project.checklist 
			@checklist = @project.checklist
			items = @checklist.checklist_items
			@item_count = items.count
			@recently_completed = @project.recent_feed
			current_time = Time.now
			@upcoming_items = items.select{|i| i.critical_date if i.critical_date && i.critical_date > current_time}.sort_by(&:critical_date).last(5)
			@recent_photos = @project.photos.last(5).sort_by(&:created_at).reverse
		end

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			flash[:notice] = "Project updated"
			render :edit
		end
	end 

	def destroy
		@project.update_attributes active: false, hidden: true
		redirect_to projects_path
	end

	def search
		search_term = "%#{params[:search]}%" if params[:search]
		initial = Project.search do
			fulltext search_term
			with :company_id, current_user.company.id
		end
		@projects = initial.results.uniq
		@prompt = "No search results"
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :index
		end
	end

	def checklist
		@checklist = @project.checklist
		@phase = @checklist.phases.find params[:phase_id] if params[:phase_id] 

	end   

	def checklist_item
		@item = ChecklistItem.find params[:item_id] if params[:item_id]
		@category = @item.category
		@phase = @category.phase
		@categories = @phase.categories
		@checklist = @phase.checklist
		@project = @checklist.project

		#category = @item.category
		#@next = category.checklist_items.where(:order_index => @item.order_index+1).first
		#@previous = category.checklist_items.where(:order_index => @item.order_index-1).first
	end  

	def reports
		@project = Project.find params[:id]
		redirect_to session[:previous_url] || root_url, notice:"Sorry, but you don't have access to that section.".html_safe unless params[:id] == @project.to_param
		@reports = @project.reports
	rescue
		if @project
			redirect_to project_path @project
		else
			redirect_to root_url
		end
	end

	def tasklist
		@tasklist = @project.tasklists.first_or_create
		#@connect
		@tasks = @tasklist.tasks
		@task = Task.find params[:task_id] if params[:task_id]
	end

	def search_tasklist
		if params[:search] && params[:search].length > 0
			search_term = "%#{params[:search]}%" 
			@project = Project.find params[:id]
			initial = Task.search do
				fulltext search_term
				with :project_id, params[:id]
			end
			@tasks = initial.results.uniq
			@prompt = "No search results"
		else
			@tasks = @project.tasklists.map(&:tasks).flatten.sort_by{|r| r.created_at}
		end

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :tasklist
		end
	end

	# def documents
	# 	@photos = @project.photos.sort_by(&:created_date).reverse
	# 	@folders = @project.folders
	# 	@nav = "all-photos-nav"
	# 	if request.xhr?
	# 		respond_to do |format|
	# 			format.js { render :template => "projects/photos"}
	# 		end
	# 	else 
	# 		render :documents
	# 	end
	# end

	def documents
		@photos = @project.photos.where(source: "Documents").sort_by(&:created_date).reverse
		@p = @photos.first
		@folders = @project.folders
		@new_photo = Photo.new
		@nav = "document-photos-nav"
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :documents
		end
	end	
	
	def checklist_photos
		@photos = @project.photos.where(source: "Checklist").order('created_at DESC')
		@p = @photos.first
		@folders = @photos.map(&:folder).flatten
		@nav = "checklist-photos-nav"
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/photos"}
			end
		else 
			render :documents
		end
	end	
	def tasklist_photos
		@photos = @project.photos.where(:source => "Tasklist").order('created_at DESC')
		@folders = @photos.map(&:folder).flatten
		@p = @photos.first
		@nav = "tasks-hotos-nav"
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/photos"}
			end
		else 
			render :documents
		end
	end	
	def report_photos
		@photos = @project.photos.where(:source => "Reports").order('created_at DESC')
		@folders = @photos.map(&:folder).flatten
		@p = @photos.first
		@nav = "report-photos-nav"
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/photos"}
			end
		else 
			render :documents
		end
	end	

	def show_photo
		@photos = @project.photos.sort_by(&:created_date).reverse
		@folders = @photos.map(&:folder).flatten
		@p = Photo.find params[:photo_id]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :documents
		end
	end

	def hide
		project_user = current_user.project_users.where(:project_id => @project.id).first
		project_user.hide_project

		reset_projects

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :index
		end
	end

	def activate
		project_user = current_user.project_users.where(:project_id => @project.id).first
		project_user.update_attribute :hidden, false if project_user

		reset_projects

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :index
		end
	end


	def destroy_confirmation
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :destroy_confirmation
		end
	end

	def order_projects
		puts "request: #{params}"
		if params[:project]
			params[:project].each_with_index do |p,i|
				project = Project.where(id: p).first
				project.update_attribute :order_index, i if project
			end
		end
		if params[:project_id]
			project = Project.where(id: params[:project_id]).first
			if project && params[:group_id]
				params[:group_id] = nil if params[:group_id] == 'undefined'
				project.update_attribute :project_group_id, params[:group_id]
			end
		end

		if request.xhr?
			respond_to do |format|
				format.js
			end
		end
	end

	private

	def reset_projects
		if current_user.any_admin?
            @sidebar_projects = current_user.company.projects.where("hidden = ? and project_group_id IS NULL",false).order('order_index')
            @projects = current_user.company.projects.where(core: false)
        else
            @sidebar_projects = current_user.project_users.where("hidden = ? and project_group_id IS NULL",false).map{|p| p.project if p.project.company_id == current_user.company_id}.compact.uniq.sort_by(&:order_index)
            @projects = current_user.project_users.where("hidden = ?",false).map{|p| p.project if p.project.company_id == current_user.company_id}.compact.uniq.sort_by(&:order_index)
        end
    
        @hidden_projects = current_user.project_users.where(hidden: true).map(&:project).compact.uniq     
        @demo_projects = Project.where(core: true)
        @project_groups = current_user.company.project_groups if current_user.company
        tasks = current_user.connect_tasks(nil)
        @companies = tasks.map{|t| t.tasklist.project.company}.compact.uniq if tasks && tasks.count > 0
	end

	def fetch
		if params[:user_id].present? && current_user.uber_admin
			@user = User.where(:id => params[:user_id]).first
		else
			@user = current_user
		end
		
		@company = @user.company
		@users = @company.users
		@subs = @company.company_subs
		
		if current_user
			if @project
				@items = current_user.connect_tasks(@project)
			else
				@items = current_user.connect_tasks(nil)
			end
			@companies = @items.map{|t| t.tasklist.project.company}.uniq
      	end
	end

	def find_project
		if params[:id].present?
			@project = Project.find params[:id] unless params[:id] == "search" || params[:id] == "delete_task"
		end
		if @project && !@project.core && !@project.users.include?(@user) && params[:id] != @project.to_param
			if request.xhr?
				respond_to do |format|
					format.js {render template: "projects/no_access"}
				end
			else
				flash[:notice] = "You don't have access to that project.".html_safe
				redirect_to root_url
			end
		end
	rescue
		redirect_to root_url, notice:"Sorry, something went wrong with your previous request. Please try again soon.".html_safe
	end
end
