class Api::V3::ReportsController < Api::V3::ApiController

    before_filter :refactor

    def create
        current_user = User.find params[:report][:author_id]
        project = Project.find params[:report][:project_id]
        reports_with_type = project.reports.where(:report_type => params[:report][:report_type])
        if reports_with_type && reports_with_type.map(&:date_string).include?(params[:report][:date_string])
            render json: {duplicate: "#{params[:report][:date_string]}"}
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
                    report.project.companies << company unless report.project.companies.flatten.include?(company)
                    report_company = report.report_companies.where(:company_id => company.id).first_or_create
                    report_company.update_attribute :count, c[:count]
                end
            end
            if subs
                subs.each do |s|
                    sub = Sub.where(:name => s[:name], :company_id => current_user.company.id).first_or_create
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

            report.activities.create(
                :project_id => report.project.id,
                :activity_type => report.class.name,
                :user_id => current_user.id,
                :body => "#{current_user.full_name} created this report." 
            )

            respond_to do |format|
                format.json { render_for_api :reports, :json => report, :root => :report}
            end
        end
    end

    def update
        ##API compatibility
        if params[:report][:author_id]
            current_user = User.find params[:report][:author_id]
            params[:report].delete(:author_id)
        ##
        else
            current_user = User.find params[:user_id] 
        end
        
    	report = Report.find params[:id]
        if params[:report][:report_users].present?
            users = params[:report][:report_users]
            user_ids = []
            users.each do |u|
                if u[:id]
                    user = User.where(:id => u[:id]).first
                elsif u[:full_name]
                    user = User.where(:full_name => u[:full_name]).first
                end
                    
                if user
                    ru = report.report_users.where(:user_id => user.id).first_or_create
                    ru.update_attribute :hours, u[:hours]
                    user_ids << user.id
                end
            end
            # clean out any report users not included in the most recent update
            report.report_users.each do |ru|
                ru.destroy unless user_ids.include?(ru.user_id) #|| connect_user_ids.include?(ru.connect_user_id)
            end
            params[:report].delete(:report_users)
        end

        if params[:report][:report_companies].present?
            companies = params[:report][:report_companies]
            company_ids = []
            companies.each do |c|
                if c[:name]
                    company = Company.where(:name => c[:name]).first
                elsif c[:id]
                    company = Company.where(:id => c[:id]).first
                end

                if company
                    report.project.companies << company unless report.project.companies.flatten.include?(company)
                    rc = report.report_companies.where(:company_id => company.id).first_or_create
                    rc.update_attribute :count, c[:count]
                    company_ids << company.id
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
                sub = Sub.where(:name => s[:name], :company_id => current_user.company.id).first_or_create
                the_sub = report.report_subs.where(:sub_id => sub.id).first_or_create
                the_sub.update_attribute :count, s[:count]
            end
            params[:report].delete(:report_subs)
        end

        if params[:report][:safety_topics].present?
            new_topics = []
            params[:report][:safety_topics].each do |topic|
                if topic["topic_id"]
                    t = report.report_topics.where(:safety_topic_id => topic["topic_id"]).first_or_create
                    new_topics << t
                else
                    if topic["id"].present?
                        t = report.report_topics.where(:safety_topic_id => topic["id"]).first_or_create
                        new_topics << t
                    else
                        new_topic = report.project.company.safety_topics.where(:title => topic["title"]).first_or_create
                        t = report.report_topics.create(:safety_topic_id => new_topic.id)
                        new_topics << t
                    end
                end
            end
            topics_for_deletion = report.report_topics - new_topics
            puts "topics for deletion: #{topics_for_deletion}"
            topics_for_deletion.each do |td|
                puts "topic to delete: #{td.title}"
                td.destroy
            end
            params[:report].delete(:safety_topics)
        end

        ## finally. an update.
    	report.update_attributes params[:report]

        report.activities.create(
            :project_id => report.project.id,
            :activity_type => report.class.name,
            :user_id => current_user.id,
            :body => "#{current_user.full_name} updated this report." 
        )

    	respond_to do |format|
        	format.json { render_for_api :reports, :json => report, :root => :report}
      	end
    end

    def show
    	project = Project.find params[:id]
        if project.reports 
        	respond_to do |format|
            	format.json { render_for_api :reports, :json => project.reports.sort_by(&:date_for_sort).reverse, :root => :reports}
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
            format.json { render_for_api :reports, :json => company_topics, :root => :possible_topics}
        end
        
    end

    def review_report
        project = Project.find params[:id]
        if params[:date_string]
            date_string = params[:date_string].gsub '-','/' 
            report = project.reports.where(:date_string => date_string).last
        end
        if report 
            respond_to do |format|
                format.json { render_for_api :reports, :json => report, :root => :report}
            end
        else
            render :json => {:success => false}
        end
    end

    def remove_personnel
        report = Report.find params[:report_id]
        if params[:sub_id]
            rs = report.report_subs.where(:sub_id => params[:sub_id]).first
            if rs && rs.destroy
                render :json=>{:success=>true}
            else
                render :json=>{:success=>false}
            end
        elsif params[:user_id]
            ru = report.report_users.where(:user_id => params[:user_id]).first
            if ru && ru.destroy
                render :json=>{:success=>true}
            else
                render :json=>{:success=>false}
            end
        elsif params[:company_id]
            rc = report.report_companies.where(:company_id => params[:company_id]).first
            if rc && rc.destroy
                render :json=>{:success=>true}
            else
                render :json=>{:success=>false}
            end
        # elsif params[:connect_user_id]
        #     ru = report.report_users.where(:connect_user_id => params[:connect_user_id]).first
        #     if ru && ru.destroy
        #         render :json=>{:success=>true}
        #     else
        #         render :json=>{:success=>false}
        #     end
        elsif params[:report_user_id]
            ru = report.report_users.where(:id => params[:report_user_id]).first
            if ru && ru.destroy
                render :json=>{:success=>true}
            else
                render :json=>{:success=>false}
            end
        else 
            render json: {success: false}
        end
    end

    def destroy
        report = Report.where(id: params[:id]).first
        if report && report.destroy
            render :json=>{:success=>true}
        else
            render :json=>{:success=>false}
        end
    end

    private

    def refactor
        if params[:report] && params[:report][:created_date]
            params[:report][:date_string] = params[:report][:created_date]
            params[:report].delete(:created_date)
        end
    end
end
