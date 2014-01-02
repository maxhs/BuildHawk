class Api::V1::ReportsController < Api::V1::ApiController

    def update
        @current_user = User.find params[:author_id] 
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
                end
            end
            params[:report].delete(:users)
        end

        if params[:report][:subs].present?
            subs = params[:report][:subs]
            subs.each do |s|
                puts "s: #{s} and :#{s[:name]}"
                sub = Sub.find_by name: s[:name]
                if sub
                    the_sub = report.report_subs.where(:sub_id => sub.id).first_or_create
                    the_sub.update_attributes :count => u[:count], :company_id => @current_user.company.id
                    puts "found a sub for report: #{the_sub.name}"
                else 
                    the_sub = report.report_subs.create :name => s[:name], :count => u[:count], :company_id => @current_user.company.id
                    puts "creating a new report sub: #{the_sub.name}"
                end
            end
            params[:report].delete(:subs)
        end

    	report.update_attributes params[:report]
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
