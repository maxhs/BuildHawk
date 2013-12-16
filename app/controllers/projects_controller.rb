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
		@projects = current_user.company.projects if current_user.company

		if request.xhr?
			respond_to do |format|
				format.js
			end
		end
	end

	def show
		@projects = current_user.company.projects if current_user.company
		@project = Project.find params[:id]
		if @project.checklist 
			@checklist = @project.checklist
			items = @checklist.checklist_items
			@item_count = items.count

			@recently_completed = items.select{|i| i.status == "Completed"}.sort_by(&:completed_date).last(5)
			@upcoming_items = items.select{|i| i.critical_date}.sort_by(&:critical_date).last(5)
			@recent_photos = @project.photos.last(5)
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
		@users = current_user.company.users
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
		@projects = current_user.company.projects
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
		redirect_to users_admin_index_path
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
		render :checklist
	end

	def category
		@category = Category.find params[:category_id]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :category
		end
	end

	def update_category
		@category = Category.find params[:category_id]
		if params[:category][:milestone_date].present?
			datetime = Date.strptime(params[:category][:milestone_date].to_s,"%m/%d/%Y").to_datetime + 12.hours
			@category.update_attribute :milestone_date, datetime
		end
		if params[:category][:name].present?
			@category.update_attribute :name, params[:category][:name]
		end

		@checklist = @project.checklist
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/checklist" }
			end
		else
			render :checklist
		end
	end

	def worklist
		@punchlist = @project.punchlists.first
		@items = @punchlist.punchlist_items if @punchlist
	end

	def reports
		@reports = @project.reports
	end

	def new_report
		@report = Report.new
		@report.users.build
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
			render :reports
		end
	end

	def show_report
		@report_title = ""
		@report = Report.find params[:report_id]
		@report.users.build
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

	def photos
		@photos = @project.photos
		if request.xhr? && remotipart_submitted?
			respond_to do |format|
				format.js
			end
		else 
			render :photos
		end
	end	

	def new_worklist_item
		@punchlist_item = PunchlistItem.new
		@punchlist_item.photos.build
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			redirect_to worklist_project_path(@project)
		end
	end

	def worklist_item
		@project = Project.find params[:project_id]
		if @project.punchlists.count == 0
			@punchlist = @project.punchlists.create
		else
			@punchlist = @project.punchlists.first
		end
		if params[:punchlist_item][:assignee].present?
			user = User.find_by(full_name: params[:punchlist_item][:assignee])
			params[:punchlist_item].delete(:assignee)
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
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			redirect_to worklist_project_path(@project)
		end
	end

	def update_worklist_item
		@punchlist_item = PunchlistItem.find params[:punchlist_item_id]
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
	end

	def photo
		@photo = @project.photos.create params[:photo]
		@photo.update_attributes :company_id => params[:company_id],:user_id => params[:user_id]
		redirect_to photos_project_path(@project)
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

	private

	def find_project
		@project = Project.find params[:id] if params[:id]
		@company = current_user.company
		@projects = @company.projects
		@users = current_user.company.users
	end

end
