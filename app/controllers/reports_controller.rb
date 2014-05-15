class ReportsController < ApplicationController
	before_filter :authenticate_user!
	before_filter :find_project

	def index
		@project = Project.find params[:project_id]
		@reports = @project.ordered_reports
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
		@report.subs.build
		@report.report_subs.build
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
		@project = Project.find params[:project_id]
		@report = Report.find params[:id]

		if params[:report_subs].present?
			params[:report_subs].each do |rs|
				report_sub = @report.report_subs.where(:sub_id => rs.first).first
				if rs[1].to_i > 0
					unless report_sub
						report_sub = @report.report_subs.create :sub_id => rs.first
						#params[:report][:sub_ids] = [] unless params[:report][:sub_ids]
						#params[:report][:sub_ids] << rs.first
					end
					report_sub.update_attribute :count, rs[1]
				#elsif params[:report][:sub_ids].present?
				else
					report_sub.destroy if report_sub
					#params[:report][:sub_ids].delete(rs.first)
				end
			end
		end

		#unless params[:report][:sub_ids].present?
		#	params[:report][:sub_ids] = nil
		#end
		unless params[:report][:created_date] == @report.created_date && params[:report][:report_type] == @report.report_type
			if @project.reports.where(:created_date => params[:report][:created_date], :report_type => params[:report][:report_type]).first
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
		
		@reports = @project.ordered_reports
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "reports/index"}
			end
		else 
			render :index
		end
	end

	def create
		@project = Project.find params[:report][:project_id]
		if @project.reports.where(:created_date => params[:report][:created_date], :report_type => params[:report][:report_type]).first
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
		@report = @project.reports.create params[:report]
		if @report.photos
			@report.photos.each do |p|
				p.update_attribute :user_id, current_user.id
			end
		end
		@reports = @project.ordered_reports
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "reports/index"}
			end
		else 
			redirect_to reports_project_path(@project)
		end
	end

	def show
		@report_title = ""
		@report = Report.find params[:id]
		@report.users.build
		@report.subs.build
		reports = @project.ordered_reports
		index = reports.index(@report)
		@next = reports[index-1] if reports[index-1].created_at > @report.created_at
		@previous = reports[index+1] if reports[index+1].created_at < @report.created_at
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
		@report = Report.find params[:id]
		if @report.destroy
			redirect_to reports_path(:project_id => @project.id)
		end
	end

	private

	def find_project
		@report = Report.where(:id => params[:id]).first
		if params[:project_id].present?
			@project = Project.find params[:project_id]
			@company = @project.company
			@projects = @company.projects
			@users = @company.users
			@subs = @company.subs
		elsif @report && @report.project_id
			@project = @report.project
			@company = @project.company
			@projects = @company.projects
			@users = @company.users
			@subs = @company.subs
		end
	end
end
