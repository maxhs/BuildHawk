class Api::V2::ReportsController < Api::V2::ApiController

    def update
        @current_user = User.find params[:report][:author_id] 
    	report = Report.find params[:id]
        if params[:report][:report_users].present?
            users = params[:report][:report_users]
            users.each do |u|
                if u[:id]
                    user = User.where(:id => u[:id]).first
                elsif u[:full_name]
                    user = User.where(:full_name => u[:full_name]).first
                end
                    
                if user
                    ru = report.report_users.where(:user_id => u[:id]).first_or_create
                    ru.update_attribute :hours, u[:hours]
                end
            end
            params[:report].delete(:report_users)
        end

        if params[:report][:report_companies].present?
            companies = params[:report][:report_companies]
            companies.each do |c|
                puts "c: #{c}"
                if c[:id]
                    company = Company.where(:id => c[:id]).first
                elsif c[:name]
                    company = Company.where(:name => c[:name]).first
                end
                    
                if company
                    rc = report.report_companies.where(:company_id => company.id).first_or_create
                    rc.update_attribute :count, c[:count].to_i
                end
            end
            params[:report].delete(:report_companies)
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

        if params[:report][:safety_topics].present?
            params[:report][:safety_topics].each do |topic|
                report.safety_topics.where(:title => topic["title"], :company_id => @current_user.company.id).first_or_create
            end
            params[:report].delete(:safety_topics)
        end

    	report.update_attributes params[:report]
    	respond_to do |format|
        	format.json { render_for_api :report, :json => report, :root => :report}
      	end
    end

    def show
    	project = Project.find params[:id]
        if project.reports 
        	reports = project.reports.sort_by(&:date_for_sort)#.reverse
        	respond_to do |format|
            	format.json { render_for_api :report, :json => reports, :root => :reports}
          	end
        else
            render :json => {:success => false}
        end
    end

    def options
        user = User.find params[:user_id]
        titles = SafetyTopic.where(:company_id => user.company.id).map(&:title).uniq
        company_topics = [] 
        titles.each do |t|
            company_topics << SafetyTopic.where(:company_id => user.company.id, :title => t).first
        end
    
        if company_topics.count == 0
            company_topics = SafetyTopic.where("company_id IS NULL").uniq 
        end

        respond_to do |format|
            format.json { render_for_api :report, :json => company_topics, :root => :possible_topics}
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

        if params[:report][:report_companies].present?
            companies = params[:report][:report_companies]
            params[:report].delete(:report_companies)
        end

        if params[:report][:safety_topics].present?
            topics = params[:report][:safety_topics]
            params[:report].delete(:safety_topics)
        end

        @report = Report.create params[:report]
        @report.update_attribute :mobile, true
        
        if topics && topics.count > 0
            topics.each do |topic|
                @report.safety_topics.where(:title => topic["title"], :company_id => @current_user.company.id).first_or_create
            end
        end
        
        if companies
            companies.each do |c|
                subcontractor = @current_user.company.subcontractors.where(:name => c[:name]).first_or_create
                report_company = @report.report_companies.where(:subcontractor_id => subcontractor.id).first_or_create
            end
        end
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
        photo = Photo.create params[:photo]
        photo.update_attribute :mobile, true
        respond_to do |format|
            format.json { render_for_api :report, :json => photo.report, :root => :report}
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
