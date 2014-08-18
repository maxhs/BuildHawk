class ProjectsController < ApplicationController
	before_filter :authenticate_user!
	before_filter :find_user
	before_filter :find_project

	def new
		@project = Project.new
		@users = current_user.company.users
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :new
		end
	end

	def create
		list = Checklist.find params[:checklist_id]
		@checklist = list.duplicate
		puts "Freshly duplicated checklist: #{@checklist.id}"
	    project = @company.projects.create params[:project]
	    @checklist.update_attributes :company_id => @company.id, :project_id => project.id, :core => false
		redirect_to projects_path
	end

	def index
		if params[:company_id]
			@company = Company.find params[:company_id]
			@projects = @company.projects
		else
			find_projects
		end

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :index
		end
	end

	def show
		find_projects
		if @project.checklist 
			@checklist = @project.checklist
			items = @checklist.checklist_items
			@item_count = items.count
			@recently_completed = @project.recent_feed
			current_time = Time.now
			@upcoming_items = items.select{|i| i.critical_date if i.critical_date && i.critical_date > current_time}.sort_by(&:critical_date).last(5)
			@recent_photos = @project.recent_photos(5)
		end

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
			@subs = @project.company.company_subs.sort_by!{|cs| cs.subcontractor.name}
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
		@projects = @project.company.projects
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
		@project.update_attribute :company_id, nil
		if Rails.env.production?
			@project.background_destroy
		else
			@project.destroy
		end

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
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :checklist
		end
	end   

	def checklist_item
		@item = ChecklistItem.find params[:item_id]
		category = @item.category
		@next = category.checklist_items.where(:order_index => @item.order_index+1).first
		@previous = category.checklist_items.where(:order_index => @item.order_index-1).first
	end  

	def worklist
		@worklist = @project.worklists.first_or_create
		@items = @worklist.worklist_items
	end

	def search_worklist
		if params[:search] && params[:search].length > 0
			search_term = "%#{params[:search]}%" 
			@project = Project.find params[:id]
			initial = WorklistItem.search do
				fulltext search_term
				with :project_id, params[:id]
			end
			@items = initial.results.uniq
			@prompt = "No search results"
		else
			@items = @project.worklists.map(&:worklist_items).flatten.sort_by{|r| r.created_at}
		end

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :worklist
		end
	end

	def documents
		@photos = @project.photos.sort_by(&:created_date).reverse
		@folders = @project.folders
		@nav = "all-photos-nav"
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/photos"}
			end
		else 
			render :documents
		end
	end

	def document_photos
		@photos = @project.photos.where(:source => "Documents").sort_by(&:created_date).reverse
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
		@photos = @project.photos.where(:source => "Checklist").order('created_at DESC')
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
	def worklist_photos
		@photos = @project.photos.where(:source => "Worklist").order('created_at DESC')
		@folders = @photos.map(&:folder).flatten
		@p = @photos.first
		@nav = "worklist-photos-nav"
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

	def archive
		project_user = current_user.project_users.where(:project_id => @project.id).first
		project_user.update_attribute :archived, true if project_user
		find_projects
		if request.xhr?
			respond_to do |format|
				format.js { render template:"projects/index" }
			end
		else
			render :index
		end
	end

	def unarchive
		project_user = current_user.project_users.where(:project_id => @project.id).first
		project_user.update_attribute :archived, false if project_user
		find_projects
		if request.xhr?
			respond_to do |format|
				format.js { render template:"projects/index" }
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
		if request.xhr?
			render json:{success:true}
		end
	end

	private

	def find_user
		if params[:user_id].present?
			@user = User.where(:id => params[:user_id]).first
		else
			@user = current_user
		end
		@company = @user.company
		@users = @company.users
		@subs = @company.company_subs

		project = Project.where(:id => params[:project_id]).first if params[:project_id]
		if current_user
			if project
				@items = current_user.connect_items(project)
			else
				@items = current_user.connect_items(nil)
			end
			@companies = @items.map{|t| t.worklist.project.company}.uniq
      	end
	end

	def find_project
		if params[:id].present?
			@project = Project.find params[:id] unless params[:id] == "search" || params[:id] == "delete_worklist_item"
		end
		if @project && !@project.users.include?(@user) && params[:id] != @project.to_param
			if request.xhr?
				respond_to do |format|
					format.js {render template: "projects/no_access"}
				end
			else
				flash[:notice] = "You don't have access to that project.".html_safe
				redirect_to root_url
			end
		else
			find_projects
		end
		
	end

	def find_projects
		if @user.company_admin? || @user.admin?
			@projects = @company.projects
			@archived_projects = current_user.project_users.where(:archived => true).map(&:project)
		else
			@projects = @user.project_users.where(:archived => false).map{|p| p.project if p.project.company_id == @user.company_id}.compact.uniq
			@archived_projects = @user.project_users.where(:archived => true).map(&:project).compact.uniq
		end
	end

end
