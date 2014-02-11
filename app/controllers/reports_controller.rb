class ReportsController < ApplicationController

	def update
		@project = Project.find params[:id]
		@report = Report.find params[:report_id]
		unless params[:report][:created_date] == @report.created_date
			puts "why is it getting in here?"
			if Report.where(:created_date => params[:report][:created_date]).first
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
		if Report.where(:created_date => params[:report][:created_date]).first
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


end
