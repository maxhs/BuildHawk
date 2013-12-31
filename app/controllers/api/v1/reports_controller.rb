class Api::V1::ReportsController < Api::V1::ApiController

    def update
    	report = Report.find params[:id]
        if params[:report][:users].present?
            users = params[:report][:users]
            users.each do |u|
                puts "u: #{u} and :#{u[:name]}"
                user = User.find_by full_name: u[:name]
                if user
                    ru = report.report_users.where(:user_id => user.id).first_or_create
                    ru.update_attribute :count, u[:count]
                    puts "creating a new report user: #{user.full_name}"
                else
                    report_sub = report.report_subs.create :count => u[:count], :name => u[:name]
                    puts "just created a new report sub: #{report_sub}" 
                end
            end
            params[:report].delete(:users)
        end
    	report.update_attributes params[:report]
        #project = report.project
        #@reports = project.reports
    	respond_to do |format|
        	format.json { render_for_api :report, :json => report, :root => :report}
      	end
    end

    def show
    	project = Project.find params[:id]
    	reports = project.reports.sort_by(&:created_date)
    	respond_to do |format|
        	format.json { render_for_api :report, :json => reports, :root => :reports}
      	end
    end

    def create
        @report = Report.create params[:report]
        respond_to do |format|
            format.json { render_for_api :report, :json => @report, :root => :report}
        end
    end

    def photo
        report = Report.find params[:id]
        report.photos.create params[:photo]
        respond_to do |format|
            format.json { render_for_api :report, :json => report, :root => :report}
        end
    end

end
