class Api::V2::ReportsController < Api::V2::ApiController

    def update
        ##API compatibility
        if params[:report][:author_id]
            @current_user = params[:report][:author_id]
            params[:report].delete(:author_id)
        ##
        else
            @current_user = User.find params[:user_id] 
        end
        
    	report = Report.find params[:id]
        if params[:report][:report_users].present?
            users = params[:report][:report_users]
            user_ids = []
            users.each do |u|
                if u[:full_name]
                    user = User.where(:full_name => u[:full_name]).first
                elsif u[:id]
                    user = User.where(:id => u[:id]).first
                end
                    
                if user
                    ru = report.report_users.where(:user_id => user.id).first_or_create
                    ru.update_attribute :hours, u[:hours]
                    user_ids << user.id
                end
            end
            report.report_users.each do |ru|
                ru.destroy unless user_ids.include?(ru.user_id)
            end
            params[:report].delete(:report_users)
        end

        if params[:report][:report_companies].present?
            companies = params[:report][:report_companies]
            company_ids = []
            companies.each do |c|
                if c[:name]
                    company = Company.where(:name => c[:name]).first
                    
                    if company
                        rc = report.report_companies.where(:company_id => company.id).first_or_create
                        rc.update_attribute :count, c[:count]
                        company_ids << company.id
                    end
                end
            end
            report.report_companies.each do |rc|
                rc.destroy unless company_ids.include?(rc.company_id)
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
                if topic["topic_id"]
                    report.report_topics.where(:safety_topic_id => topic["topic_id"]).first_or_create
                else
                    if topic["id"].present?
                        report.report_topics.where(:safety_topic_id => topic["id"]).first_or_create
                    else
                        new_topic = report.project.company.safety_topics.where(:title => topic["title"]).first_or_create
                        report.report_topics.create(:safety_topic_id => new_topic.id)
                    end
                end
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
        	reports = project.reports.sort_by(&:date_for_sort).reverse
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
    
        SafetyTopic.where("company_id IS NULL and core = ?",true).each do |topic|
            company_topics << topic  
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
        project = Project.find params[:report][:project_id]
        reports_with_type = project.reports.where(:report_type => params[:report][:report_type])
        if reports_with_type && reports_with_type.map(&:created_date).include?(params[:report][:created_date])
            render json: {duplicate: "#{params[:report][:created_date]}"}
        else
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

            report = Report.create params[:report]
            report.update_attribute :mobile, true
            
            if topics
                topics.each do |topic|
                    if topic["topic_id"]
                        report.report_topics.where(:safety_topic_id => topic["topic_id"]).first_or_create
                    else
                        if topic["id"].present?
                            report.report_topics.where(:safety_topic_id => topic["id"]).first_or_create
                        else
                            new_topic = report.project.company.safety_topics.where(:title => topic["title"]).first_or_create
                            report.report_topics.create(:safety_topic_id => new_topic.id)
                        end
                    end
                end
            end
            
            if companies
                companies.each do |c|
                    company = Company.where(:name => c[:name]).first_or_create
                    report_company = report.report_companies.where(:company_id => company.id).first_or_create
                    report_company.update_attribute :count, c[:count]
                end
            end
            if subs
                subs.each do |s|
                    sub = Sub.where(:name => s[:name], :company_id => @current_user.company.id).first_or_create
                    the_sub = report.report_subs.where(:sub_id => sub.id).first_or_create
                    the_sub.update_attribute :count, s[:count]
                end
            end

            if users
                users.each do |u|
                    user = User.find_by full_name: u[:full_name]
                    if user
                        ru = report.report_users.where(:user_id => user.id).first_or_create
                        ru.update_attribute :hours, u[:hours]
                    end
                end
            end

            respond_to do |format|
                format.json { render_for_api :report, :json => report, :root => :report}
            end
        end
    end

    def photo
        if params[:photo]
            photo = Photo.create params[:photo]
            photo.update_attribute :mobile, true
            respond_to do |format|
                format.json { render_for_api :report, :json => photo.report, :root => :report}
            end
        elsif params[:photos]
            params[:photos].each do |p|
                photo = Photo.new(image: p)
                photo.save
                photo.update_attributes params[:photo]
            end
            report = Report.find params[:photo][:report_id]
            respond_to do |format|
                format.json { render_for_api :report, :json => report, :root => :report}
            end
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
        elsif params[:company_id].present?
            rc = report.report_companies.where(:company_id => params[:company_id]).first
            if rc && rc.destroy
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

    def destroy
        report = Report.find params[:id]
        if report.destroy
            render :json=>{:success=>true}
        else
            render :json=>{:success=>false}
        end
    end
end
