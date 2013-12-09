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
		@items = @project.checklist.checklist_items.where(:complete => true)
		puts "item count: #{@items.count}"
		@checklist = @project.checklist
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
		@project.destroy
		redirect_to projects_path
	end

	def checklist
		@checklist = @project.checklist
		puts "did we find a checklist? #{@checklist} #{@checklist.categories.count} #{@checklist.categories.map(&:subcategories).flatten.count}"
	end     

	def checklist_item
		@checklist_item = ChecklistItem.find params[:id]
	end

	def punchlists
		@punchlist = @project.punchlists.first
		@items = @punchlist.punchlist_items if @punchlist
	end

	def reports
		@reports = @project.reports
	end

	def new_report
		@report = Report.new
		@report.report_users.build
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
		redirect_to reports_project_path(@project)
	end

	def show_report
		@report_title = ""
		@report = Report.find params[:report_id]
		@report.report_users.build
	end

	def update_report
		@report = Report.find params[:report_id]
		if params[:report][:report_users].present?
			r_users = params[:report][:report_users]
			r_users.each do |r|
				if r.length > 0
					puts "this is r: #{r}"
					u = User.where(:full_name => r, :company_id => @project.company.id).first_or_create
					ru = ReportUser.where(:user_id => u.id, :report_id => @report.id).first_or_create
					@report.report_users << ru
				end
			end
			params[:report].delete(:report_users)
		end
		@report.update_attributes params[:report]
		@reports = @project.reports
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "reports"}
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

	def new_punchlist_item
		@punchlist_item = PunchlistItem.new
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			redirect_to punchlists_project_path(@project)
		end
	end

	def punchlist_item
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
		@punchlist_item.update_attribute :assignee_id, user.id if user
		redirect_to project_path(@project)
	end

	def edit_punchlist_item
		@punchlist_item = PunchlistItem.find params[:item_id]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			redirect_to punchlists_project_path(@project)
		end
	end

	def update_punchlist_item
		@punchlist_item = PunchlistItem.find params[:id]
		@punchlist_item.update_attributes params[:punchlist_item]
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

	def delete_punchlist_item
		@item = PunchlistItem.find params[:item_id]
		@item.destroy
		redirect_to punchlists_project_path(@project)
	end

	private

	def find_project
		@project = Project.find params[:id] if params[:id]
		@company = current_user.company
		@projects = @company.projects
		@users = current_user.company.users
	end

end
