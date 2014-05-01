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
		@checklist.save

	    project = @company.projects.create params[:project]
	    @checklist.update_attributes :company_id => @company.id, :project_id => project.id, :core => false
		puts "is it getting the new company id? #{@checklist.company.id} and project? #{@checklist.project_id}"
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
			@recent_photos = @project.photos.last(5).sort_by(&:created_at).reverse
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
			@subs = @project.company.subs
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
        @project.background_destroy
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
	end  

	def worklist
		@punchlist = @project.punchlists.first_or_create
		@items = @punchlist.punchlist_items
	end

	def export_checklist
		item = ChecklistItem.find params[:checklist_item_id]
		params[:names].each do |r|
			puts "r: #{r}"
			recipient = User.where(:full_name => r).first
			recipient = Sub.where(:name => r).first unless recipient
			ChecklistMailer.export(recipient.email, item, @project).deliver
		end
		params[:email].split(',').each do |e|
			ChecklistMailer.export(e, item, @project).deliver
		end

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :checklist
		end
	end

	def search_worklist
		if params[:search] && params[:search].length > 0
			search_term = "%#{params[:search]}%" 
			@project = Project.find params[:id]
			initial = PunchlistItem.search do
				fulltext search_term
				with :project_id, params[:id]
			end
			@items = initial.results.uniq
			@prompt = "No search results"
		else
			@items = @project.punchlists.map(&:punchlist_items).flatten.sort_by{|r| r.created_at}
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
		@photos = @project.photos.where(:source => "Checklist")
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
		@photos = @project.photos.where(:source => "Worklist")
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
		@photos = @project.photos.where(:source => "Reports")
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

	private

	def find_user
		if params[:user_id].present?
			@user = User.where(:id => params[:user_id]).first
		else
			@user = current_user
		end
		@company = @user.company
		@users = @company.users
		@subs = @company.subs
	end

	def find_project
		if params[:id].present?
			@project = Project.find params[:id] unless params[:id] == "search" || params[:id] == "delete_worklist_item"
		end
		find_projects
	end

	def find_projects
		if @user.company_admin? || @user.admin?
			@projects = @company.projects
			@archived_projects = current_user.project_users.where(:archived => true).map(&:project)
		else
			@projects = @user.project_users.where(:archived => false).map(&:project).compact.uniq
			@archived_projects = @user.project_users.where(:archived => true).map(&:project).compact.uniq
		end
	end

end
