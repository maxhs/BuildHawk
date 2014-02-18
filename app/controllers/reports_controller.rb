class ReportsController < ApplicationController

	def update
		@project = Project.find params[:id]
		@report = Report.find params[:report_id]
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
				format.js { render :template => "projects/reports"}
			end
		else 
			render :reports
		end
	end

	def create
		@project = Project.find params[:id]
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
		@reports = @project.ordered_reports
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/reports"}
			end
		else 
			redirect_to reports_project_path(@project)
		end
	end

	def generate
		@report = Report.find params[:id]
		ReportMailer.report(@report,current_user).deliver
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/report_generated"}
			end
		else 
			flash[:notice] = "Report emailed to #{current_user.email}".html_safe
			redirect_to show_report_project_path(@project)
		end
	end
end
