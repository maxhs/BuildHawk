class ReportsController < AppController
	before_filter :authenticate_user!
	before_filter :find_project
	require 'forecast_io'
	include ReportsHelper
	ForecastIO.api_key = '32a0ebe578f183fac27d67bb57f230b5'

	def index
		@project = Project.find params[:p]
		redirect_to session[:previous_url] || root_url, notice:"Sorry, but you don't have access to that section.".html_safe unless params[:p] == @project.to_param
		@reports = @project.reports
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
			@reports = @project.reports
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
		@reports = @project.reports
		@report = Report.new
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

		if params[:report_users]
			params[:report_users].each do |ru|
				report_user = @report.report_users.where(:user_id => ru.first).first_or_create
				if ru[1].to_i > 0
					report_user.update_attribute :hours, ru[1]
				else
					report_user.destroy if report_user
				end
			end
		end

		if params[:report][:safety_topics]
			params[:report][:safety_topics].each do |safety_topic_id|
				unless safety_topic_id.nil? || safety_topic_id.length == 0
					@report.report_topics.where(safety_topic_id: safety_topic_id).first_or_create
				end
			end
			params[:report].delete(:safety_topics)
		end
		
		@report.update_attributes params[:report]
		
		@report.activities.create(
            :project_id => @report.project.id,
            :activity_type => @report.class.name,
            :user_id => current_user.id,
            :body => "#{current_user.full_name} updated this report." 
        )

		@reports = @project.reports
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :index
		end
	end

	def remove_report_user
		report_user = ReportUser.find params[:id]
		@report_user_id = report_user.id
		report_user.destroy
	end

	def remove_report_company
		report_company = ReportCompany.find params[:id]
		@report_company_id = report_company.id
		report_company.destroy
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
		@reports = @project.reports
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			redirect_to reports_project_path(@project)
		end
	end

	def weather
		raw_time = params[:date].to_i if params[:date]
		report_time = Time.at(raw_time/1000.0)
		forecast(params[:latitude],params[:longitude],report_time.to_i)
		tmin = @temp_min ? @temp_min.to_f.round(1) : nil
		tmax = @temp_max ? @temp_max.to_f.round(1) : nil
		render json: {
			summary: @summary, 
			tempMin: tmin,
			tempMax: tmax, 
			windSpeed: @wind_speed,
			windBearing: wind_bearing(@bearing),
			humidity: @humidity, 
			precip: @precip
		}
	end

	def show
		@report_title = ""
		@report = Report.find params[:id]

		forecast(@project.address.latitude, @project.address.longitude, @report.report_date.to_time.to_i) unless @report.has_weather?
		@temp = @temp_min && @temp_max ? "#{@temp_min.round(1)}&deg; - #{@temp_max.round(1)}&deg;".html_safe : "N/A"
		@wind = "#{@wind_speed} #{wind_bearing(@bearing)}".html_safe
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			@reports = @project.reports
			render "projects/reports"
		end
	end

	def forecast(latitude, longitude, time)
		@forecast = ForecastIO.forecast(latitude, longitude, time: time)
		if @forecast
			@summary = @forecast.daily.data[0].summary
			@temp_min = @forecast.daily.data[0].temperatureMin
			@temp_max = @forecast.daily.data[0].temperatureMax
			@bearing = @forecast.daily.data[0].windBearing
			@wind_speed = @forecast.daily.data[0].windSpeed.round(1) if @forecast.daily.data[0].windSpeed
			@humidity = number_to_percentage(@forecast.currently.humidity*100, precision: 0) if @forecast.currently.humidity
			@precip = number_to_percentage(@forecast.currently.precipProbability*100, precision: 0) if @forecast.currently.precipProbability
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
