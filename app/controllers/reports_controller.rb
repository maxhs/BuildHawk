class ReportsController < ApplicationController

	def update
		@project = Project.find params[:id]
		@report = Report.find params[:report_id]

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
				format.js
			end
		else 
			flash[:notice] = "Report emailed to #{current_user.email}".html_safe
			redirect_to show_report_project_path(@project)
		end
	end
end
