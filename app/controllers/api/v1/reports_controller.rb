class Api::V1::ReportsController < Api::V1::ApiController

    def update
        @current_user = User.find params[:report][:author_id] 
    	report = Report.find params[:id]
        if params[:report][:report_users].present?
            users = params[:report][:report_users]
            users.each do |u|
                puts "u: #{u} and :#{u[:full_name]}"
                user = User.find_by full_name: u[:full_name]
                if user
                    ru = report.report_users.where(:user_id => user.id).first_or_create
                    puts "adding a new report user: #{user.full_name}"
                end
            end
            params[:report].delete(:report_users)
        end

        if params[:report][:report_subs].present?
            subs = params[:report][:report_subs]
            subs.each do |s|
                puts "s: #{s} and #{s[:name]}"
                sub = Sub.where(:name => s[:name], :company_id => @current_user.company.id).first_or_create
                puts "added a sub for report: #{sub.name}"
                the_sub = report.report_subs.where(:sub_id => sub.id).first_or_create
                puts "got the sub: #{the_sub.id}"
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
        if subs
            subs.each do |s|
                puts "s: #{s} and #{s[:name]}"
                sub = Sub.where(:name => s[:name], :company_id => @current_user.company.id).first_or_create
                the_sub = @report.report_subs.where(:sub_id => sub.id).first_or_create
                puts "got the sub: #{the_sub.id}"
                the_sub.update_attribute :count, s[:count]
            end
        end

        if users
            users.each do |u|
                puts "u: #{u} and :#{u[:full_name]}"
                user = User.find_by full_name: u[:full_name]
                if user
                    ru = @report.report_users.where(:user_id => user.id).first_or_create
                    puts "creating a new report user: #{user.full_name}"
                end
            end
        end

        respond_to do |format|
            format.json { render_for_api :report, :json => @report, :root => :report}
        end
    end

    def photo
        report = Report.find params[:photo][:report_id]
        report.photos.create params[:photo]
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
            if ru.destroy
                render :json=>{:success=>true}
            else
                render :json=>{:success=>false}
            end
        end
    end
end
