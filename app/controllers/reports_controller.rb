class ReportsController < AppController
	before_filter :authenticate_user!
	before_filter :find_project

	def index
		@project = Project.find params[:project_id]
		@reports = @project.ordered_reports
		@report = Report.find params[:report_id] if params[:report_id]
	rescue
		if @project
			redirect_to project_path @project
		else
			redirect_to root_url
		end
	end

	def search
		if params[:search] && params[:search].length > 0
			search_term = "%#{params[:search]}%" 
			@project = Project.find params[:project_id]
			initial = Report.search do
				fulltext search_term
				with :project_id, params[:project_id]
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

	def new
		@project = Project.find params[:project_id]
		@report = @project.reports.new
		@report.users.build
		@report.report_companies.build
		@report_title = "Add a New Report"
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			@reports = @project.reports
			render :new
		end
	end

	def update

		if params[:report_companies].present?
			params[:report_companies].each do |rc|
				report_company = @report.report_companies.where(:company_id => rc.first).first
				if rc[1].to_i > 0
					unless report_company
						report_company = @report.report_companies.create :company_id => rc.first
					end
					report_company.update_attribute :count, rc[1]
				else
					report_company.destroy if report_company
				end
			end
		end

		if params[:report_users].present?
			params[:report_users].each do |ru|
				report_user = @report.report_users.where(:user_id => ru.first).first_or_create
				if ru[1].to_i > 0
					report_user.update_attribute :hours, ru[1]
				else
					report_user.destroy if report_user
				end
			end
		end

		#unless params[:report][:sub_ids].present?
		#	params[:report][:sub_ids] = nil
		#end
		unless params[:report][:date_string] == @report.date_string && params[:report][:report_type] == @report.report_type
			if @project.reports.where(:date_string => params[:report][:date_string], :report_type => params[:report][:report_type]).first
				if request.xhr?
					respond_to do |format|
						format.js { render :template => "reports/existing"}
					end
				else 
					flash[:notice] = "A report for that date already exists"
					redirect_to reports_project_path(@project)
				end
				return
			end
		end
		
		@report.update_attributes params[:report]
		
		@report.activities.create(
            :project_id => @report.project.id,
            :activity_type => @report.class.name,
            :user_id => current_user.id,
            :body => "#{current_user.full_name} updated this report." 
        )

		@reports = @project.ordered_reports
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :index
		end
	end

	def create
		@project = Project.find params[:report][:project_id]
		@project_users = @project.project_users
		@subs = @project.companies.flatten.sort_by(&:name)

		if @project.reports.where(:date_string => params[:report][:date_string], :report_type => params[:report][:report_type]).first
			if request.xhr?
				respond_to do |format|
					format.js { render :template => "reports/existing"}
				end
			else 
				flash[:notice] = "A report for that date already exists"
				redirect_to reports_project_path(@project)
			end
			return
		end

		## ensure the report type is properly included, despite the Select2 stuff happening on the front end 
		params[:report][:report_type] = params[:report_type] if params[:report_type]
		@report = @project.reports.create! params[:report]

		@report.activities.create(
            :project_id => @report.project.id,
            :activity_type => @report.class.name,
            :user_id => current_user.id,
            :body => "#{current_user.full_name} created this report." 
        )

		if @report.photos
			@report.photos.each do |p|
				p.update_attribute :user_id, current_user.id
			end
		end
		@reports = @project.ordered_reports
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			redirect_to reports_project_path(@project)
		end
	end

	def show
		@report_title = ""
		@report = Report.find params[:id]
		@report.users.build
		@report.companies.build
		reports = @project.ordered_reports
		index = reports.index(@report)
		@next = reports[index-1] if reports[index-1] && reports[index-1].created_at > @report.created_at
		@previous = reports[index+1] if reports[index+1] && reports[index+1].created_at < @report.created_at
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			@reports = @project.ordered_reports
		end
	end

	def generate
		@report = Report.find params[:id]
		ReportMailer.report(@report,current_user).deliver
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			flash[:notice] = "Report emailed to #{current_user.email}".html_safe
			redirect_to show_report_project_path(@project)
		end
	end

	def destroy
		@project = @report.project
		@report_id = @report.id
		@report.destroy
	end

	private

	def find_project
		@report = Report.where(:id => params[:id]).first
		if params[:project_id].present?
			@project = Project.find params[:project_id]
			@company = @project.company
			@projects = @company.projects
			@project_users = @project.project_users
			@subs = @project.companies.sort_by(&:name)
		elsif @report && @report.project_id
			@project = @report.project
			@company = @project.company
			@projects = @company.projects
			@project_users = @project.project_users
			@subs = @project.companies.sort_by(&:name)
		end
	end
end
