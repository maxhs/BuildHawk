class ProjectsController < ApplicationController
	before_filter :authenticate_user!
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
		@company = current_user.company
		@project = @company.projects.create params[:project]
		redirect_to admin_index_path
	end

	def index
		if params[:company_id]
			puts "fetching projects for uber admin"
			@company = Company.find params[:company_id]
			@projects = @company.projects
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
		@project = Project.find params[:id]
		@projects = @project.company.projects
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
		@project.users.build
		unless @project.address
			@project.build_address
		end
		@users = @project.company.users
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
		@project = Project.find params[:id]
		@project.update_attributes params[:project]
		@checklist = @project.checklist
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

	def delete_checklist
		@checklist = Checklist.find params[:checklist_id]
		@checklist.destroy
		@projects = current_user.company.projects if current_user.company
		@project = Project.find params[:id]
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/show"}
			end
		else
			render :show
		end
	end

	def checklist_item
		@checklist_item = ChecklistItem.find params[:item_id]
	end

	def update_checklist_item
		@checklist_item = ChecklistItem.find params[:checklist_item_id]
		@checklist_item.update_attributes params[:checklist_item]
		@checklist = @checklist_item.subcategory.category.checklist
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :checklist
		end
	end

	def delete_item
		checklist_item = ChecklistItem.find params[:checklist_item_id]
		@item_id = checklist_item.id
		if checklist_item.destroy && request.xhr?
			respond_to do |format|
				format.js
			end
		elsif checklist_item.destroy
			render :checklist
		end
	end

	def worklist
		@punchlist = @project.punchlists.first
		@items = @punchlist.punchlist_items if @punchlist
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

	def reports
		@reports = @project.reports.sort_by{|r| r.date_for_sort}
	end

	def search_reports
		if params[:search] && params[:search].length > 0
			search_term = "%#{params[:search]}%" 
			@project = Project.find params[:id]
			initial = Report.search do
				fulltext search_term
				with :project_id, params[:id]
			end
			@reports = initial.results.uniq
			@prompt = "No search results"
		else
			@reports = @project.reports.sort_by{|r| r.date_for_sort}
		end

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :reports
		end
	end

	def new_report
		@report = Report.new
		@report.users.build
		@report.subs.build
		@report_title = "Add a New Report"
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			@reports = @project.reports
			redirect_to reports_project_path(@project)
		end
	end

	def report
		@report = @project.reports.create params[:report]
		@reports = @project.reports
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/reports"}
			end
		else 
			redirect_to reports_project_path(@project)
		end
	end

	def show_report
		@report_title = ""
		@report = Report.find params[:report_id]
		@report.users.build
		@report.subs.build
	end

	def update_report
		@report = Report.find params[:report_id]
		@report.update_attributes params[:report]
		@reports = @project.reports
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/reports"}
			end
		else 
			render :reports
		end
	end

	def documents
		@photos = @project.photos.sort_by(&:created_date).reverse
		@folders = @project.folders
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :documents
		end
	end

	def document_photos
		@photos = @project.photos.where(:source => "Documents").sort_by(&:created_date).reverse
		@p = @photos.first
		@folders = @project.folders
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
		@photos = @project.photos.where(:source => "Report")
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

	def new_worklist_item
		@punchlist_item = PunchlistItem.new
		@punchlist_item.photos.build
		@punchlist_item.build_assignee
		@users = @project.company.users
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			redirect_to worklist_project_path(@project)
		end
	end

	def worklist_item
		@project = Project.find params[:id]
		if @project.punchlists.count == 0
			@punchlist = @project.punchlists.create
		else
			@punchlist = @project.punchlists.first
		end
		if params[:punchlist_item][:assignee_attributes].present?
			user = User.find_by(full_name: params[:punchlist_item][:assignee_attributes][:full_name])
			params[:punchlist_item].delete(:assignee_attributes)
		end
		@punchlist_item = @punchlist.punchlist_items.create params[:punchlist_item]
		@items = @punchlist.punchlist_items if @punchlist
		@punchlist_item.update_attribute :assignee_id, user.id if user
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/worklist"}
			end
		else 
			render :worklist
		end
	end

	def edit_worklist_item
		@punchlist_item = PunchlistItem.find params[:item_id]
		@punchlist_item.build_assignee if @punchlist_item.assignee.nil?
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :edit_worklist_item
		end
	end

	def update_worklist_item
		@punchlist_item = PunchlistItem.find params[:punchlist_item_id]
		if params[:punchlist_item][:assignee_attributes].present?
			user = User.find_by(full_name: params[:punchlist_item][:assignee_attributes][:full_name])
			params[:punchlist_item].delete(:assignee_attributes)
			if user
				@punchlist_item.update_attribute :assignee_id, user.id
			else
				@punchlist_item.update_attribute :assignee_id, nil
			end
		end
		@punchlist_item.update_attributes params[:punchlist_item]
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/worklist"}
			end
		else 
			redirect_to worklist_project_path(@project)
		end
	end

	def new_photo
		@new_photo = Photo.new
		@folder = Folder.find params[:folder_id]
	end

	def photo
		@p = @project.photos.create! params[:photo]
		@photos = @project.photos.where(:source => "Documents").sort_by(&:created_date).reverse
		@folders = @project.folders

		unless @p.save 
			flash[:notice] = "didn't work"
		end

		redirect_to document_photos_project_path(@project)
	end

	def delete_report
		@report = Report.find params[:report_id]
		if @report.destroy
			redirect_to reports_project_path(@project)
		end
	end

	def delete_photo

	end

	def delete_worklist_item
		@item = PunchlistItem.find params[:item_id]
		@punchlist = @item.punchlist
		@items = @punchlist.punchlist_items
		@project = @punchlist.project
		@item.destroy
		render :worklist
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

	def find_project
		if params[:id].present?
			@project = Project.find params[:id] unless params[:id] == "search" || params[:id] == "delete_worklist_item"
		end
		@company = current_user.company
		@projects = @company.projects
		@users = @company.users
		@subs = @company.subs
	end

end
