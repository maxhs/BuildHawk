class Api::V2::ReportsController < Api::V2::ApiController

    def update
        @current_user = User.find params[:report][:author_id] 
    	report = Report.find params[:id]
        if params[:report][:report_users].present?
            users = params[:report][:report_users]
            users.each do |u|
                user = User.find_by full_name: u[:full_name]
                if user
                    ru = report.report_users.where(:user_id => user.id).first_or_create
                end
            end
            params[:report].delete(:report_users)
        end

        if params[:report][:report_subs].present?
            subs = params[:report][:report_subs]
            subs.each do |s|
                sub = Sub.where(:name => s[:name], :company_id => @current_user.company.id).first_or_create
                the_sub = report.report_subs.where(:sub_id => sub.id).first_or_create
                the_sub.update_attribute :count, s[:count]
            end
            params[:report].delete(:report_subs)
        end

    	report.update_attributes params[:report]
    	respond_to do |format|
        	format.json { render_for_api :report, :json => report, :root => :report}
      	end
    end

    def show
    	project = Project.find params[:id]
        if project.reports 
        	reports = project.reports.sort_by(&:date_for_sort)
        	respond_to do |format|
            	format.json { render_for_api :report, :json => reports, :root => :reports}
          	end
        else
            render :json => {:success => false}
        end
    end

    def review_report
        project = Project.find params[:id]
        if params[:date_string]
            date_string = params[:date_string].gsub '-','/' 
            report = project.reports.where(:created_date => date_string).last
        end
        if report 
            respond_to do |format|
                format.json { render_for_api :report, :json => report, :root => :report}
            end
        else
            render :json => {:success => false}
        end
    end

    def create
        @current_user = User.find params[:report][:author_id]
        if params[:report][:report_users].present?
            users = params[:report][:report_users]
            params[:report].delete(:report_users)
        end

        if params[:report][:report_subs].present?
            subs = params[:report][:report_subs]
            params[:report].delete(:report_subs)
        end
        @report = Report.create params[:report]
        @report.update_attribute :mobile, true
        if subs
            subs.each do |s|
                sub = Sub.where(:name => s[:name], :company_id => @current_user.company.id).first_or_create
                the_sub = @report.report_subs.where(:sub_id => sub.id).first_or_create
                the_sub.update_attribute :count, s[:count]
            end
        end

        if users
            users.each do |u|
                user = User.find_by full_name: u[:full_name]
                if user
                    ru = @report.report_users.where(:user_id => user.id).first_or_create
                end
            end
        end

        respond_to do |format|
            format.json { render_for_api :report, :json => @report, :root => :report}
        end
    end

    def photo
        report = Report.find params[:photo][:report_id]
        photo = report.photos.create params[:photo]
        photo.update_attribute :mobile, true
        respond_to do |format|
            format.json { render_for_api :report, :json => report, :root => :report}
        end
    end

    def remove_personnel
        report = Report.find params[:report_id]
        if params[:sub_id].present?
            rs = report.report_subs.where(:sub_id => params[:sub_id]).first
            if rs && rs.destroy
                render :json=>{:success=>true}
            else
                render :json=>{:success=>false}
            end
        elsif params[:user_id].present?
            ru = report.report_users.where(:user_id => params[:user_id]).first
            if ru && ru.destroy
                render :json=>{:success=>true}
            else
                render :json=>{:success=>false}
            end
        end
    end
end
