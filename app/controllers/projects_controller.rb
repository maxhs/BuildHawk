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

	def new_item 
		@checklist_item = ChecklistItem.new
		@item_index = params[:item_index]
		@subcategory = Subcategory.find params[:subcategory_id]
		@category = @subcategory.category
		@checklist = @category.checklist
		@category_name = @category.name
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :new_item
		end
	end

	def create_item
		index = params[:checklist_item][:item_index]
		@item = ChecklistItem.create params[:checklist_item]
		@checklist = @item.checklist
		@subcategory = @item.subcategory
		@project = Project.find params[:id]
		if request.xhr?
			respond_to do |format|
				format.js 
			end
		else
			render :checklist
		end
	end

	def new_subcategory
		@category = Category.find params[:category_id] 
		@new_subcategory = @category.subcategories.new
		if params[:subcategory_id]
			@subcategory = Subcategory.find params[:subcategory_id]
			@subcategory_id = params[:subcategory_id]
		else
			@subcategory = @category.subcategories.build
			@subcategory_id = 0
		end
		@item_index = params[:item_index]
		@checklist = @project.checklist
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :new_subcategory
		end
	end

	def create_subcategory
		@previous_subcategory_id = params[:previous_subcategory_id].html_safe
		@subcategory = Subcategory.create params[:subcategory]
		@subcategory.checklist_items.build
		@checklist = Checklist.find params[:checklist_id]
		@project = Project.find params[:id]
		if request.xhr?
			respond_to do |format|
				format.js 
			end
		else
			render :checklist
		end
	end

	def new_category
		@category = Category.find params[:category_id]
		@checklist = @category.checklist 
		@new_category = @checklist.categories.new
		@item_index = params[:item_index]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :new_category
		end
	end

	def create_category
		@previous_category_id = params[:previous_category_id].html_safe
		@category = Category.create params[:category]
		@checklist = Checklist.find params[:checklist_id]
		@project = Project.find params[:id]
		if request.xhr?
			respond_to do |format|
				format.js 
			end
		else
			render :checklist
		end
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

	def export_worklist
		item_array = []
		params[:items].each do |i|
			puts "i: #{i}"
			item_array << PunchlistItem.find(i)
		end
		puts "item array: #{item_array}"
	end

	def search_items
		if params[:search] && params[:search].length > 0
			search_term = "%#{params[:search]}%" 
			@project = Project.find params[:id]
			initial = ChecklistItem.search do
				fulltext search_term
				with :checklist_id, params[:checklist_id]
			end
			@items = initial.results.uniq
			@prompt = "No search results"
			if request.xhr?
				respond_to do |format|
					format.js
				end
			end
		else 
			@checklist = @project.checklist
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

	def reports
		@reports = @project.ordered_reports
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
			@reports = @project.ordered_reports
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

	def show_report
		@report_title = ""
		@report = Report.find params[:report_id]
		@report.users.build
		@report.subs.build
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

	def photo
		@p = Photo.new(image: params[:file])
		if params[:file].original_filename
			@p.name = params[:file].original_filename
			@p.save
		end
		@p.update_attributes :folder_id => params[:photo][:folder_id], :user_id => current_user.id, :project_id => @project.id, :company_id => @company.id
		@photos = @project.photos.where(:source => "Documents").sort_by(&:created_date).reverse
		@folders = @project.folders

		unless @p.save 
			flash[:notice] = "didn't work"
		end
		if request.xhr?
			puts "should be doing stuff!"
			respond_to do |format|
				format.js
			end
		else
			redirect_to document_photos_project_path(@project)
		end
	end

	def delete_report
		@report = Report.find params[:report_id]
		if @report.destroy
			redirect_to reports_project_path(@project)
		end
	end

	def delete_photo

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
