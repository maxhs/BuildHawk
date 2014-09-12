class Api::V3::ProjectsController < Api::V3::ApiController

    def index
        user = User.find params[:user_id]
        user.notifications.where(:read => false).each do |n| n.update_attribute :read, true end

        if user.any_admin?
            projects = user.project_users.where("archived = ? and core = ? and project_group_id IS NULL",false,false).map(&:project)
        else
            projects = user.project_users.where("archived = ? and core = ? and project_group_id IS NULL",false,false).map{|p| p.project if p.project.company_id == user.company_id}.compact.sort_by{|p| p.name.downcase}
        end

        if projects
            respond_to do |format|
                format.json { render_for_api :projects, :json => projects, :root => :projects}
            end
        else
            render :json => {success: false}
        end
    end

    def groups
        user = User.find params[:user_id]
        group_ids = user.project_users.where("project_group_id IS NOT NULL").map(&:project_group_id).uniq
        groups = []
        if group_ids.count > 0
            group_ids.each do |g|
                groups << ProjectGroup.find(g)
            end 
        end

        if groups.count > 0
            respond_to do |format|
                format.json { render_for_api :projects, :json => groups, :root => :groups}
            end
        else
            render :json => {success: false}
        end
    end

    def demo
        projects = Project.where(:core => true)
        if projects.count > 0
            respond_to do |format|
                format.json { render_for_api :projects, :json => projects, :root => :projects}
            end
        else
            render :json => {success: false}
        end
    end

    def show
        project = Project.find params[:id]
        respond_to do |format|
            format.json { render_for_api :details, :json => project, :root => :project}
        end
    end

    def find_user
        project = Project.find params[:id]
        if params[:user][:email]
            user = User.where(:email => params[:user][:email]).first
        elsif params[:user][:phone]
            phone = params[:user][:phone].gsub(/[^0-9a-z ]/i, '').gsub(/\s+/,'')
            puts "Trying to find a user with phone: #{phone}"
            user = User.where(:phone => phone).first
        end

        if user
            puts "we found a user: #{user.full_name}"
            ## existing user. ensure they're attached to the project
            project.project_users.where(:user_id => user.id).first_or_create
            respond_to do |format|
                format.json { render_for_api :user, :json => user, :root => :user}
            end
        else
            alternate = Alternate.where(:email => params[:user][:email]).first
            alternate = Alternate.where(:phone => phone).first if phone && !alternate
            if alternate
                user = alternate.user
                puts "did we find an alternate? #{user.full_name}"
                project.project_users.where(:user_id => user.id).first_or_create
                respond_to do |format|
                    format.json { render_for_api :user, :json => user, :root => :user}
                end
            else
                
                render json: {success: false}
            end
        end
    end

    def add_user
        project = Project.find params[:id]
        if params[:user][:company_name]
            company_name = "#{params[:user][:company_name]}"
            company = Company.where("name ILIKE ?",company_name).first
            company = Company.create :name => company_name unless company
            params[:user][:company_id] = company.id

            ## create a new project subcontractor object for the project
            project.project_subs.create :company_id => company.id
            ## create a new company subcontractor object for the company that owns the project
            project.company.company_subs.where(:subcontractor_id => company.id).first_or_create 
            #params[:user].delete(:company_name)
        end
       
        task = WorklistItem.find params[:task_id] if params[:task_id] && params[:task_id] != 0
        report = Report.find params[:report_id] if params[:report_id] && params[:report_id] != 0

        email = params[:user][:email].strip if params[:user][:email]
        puts "do we have an email? #{email}"
        phone = params[:user][:phone].gsub(/[^0-9a-z ]/i, '').gsub(/\s+/,'') if params[:user][:phone]
        puts "do we have a phone? #{phone}"

        user = User.where(:email => email).first
        user = User.where(:phone => phone).first unless user

        if user
            ## existing user. ensure they're attached to the project
        else
            alternate = Alternate.where(:email => email).first if email
            alternate = Alternate.where(:phone => phone).first if phone && !alternate
            user = alternate.user if alternate
        end
        
        if user
            project.project_users.where(:user_id => user.id).first_or_create
            project.project_subs.where(:company_id => user.company_id).first_or_create if user.company_id

            if task
                if email && user.email_permissions
                    user.email_task(task)
                elsif phone && user.text_permissions
                    user.text_task(task)
                end
            elsif report
                report.report_users.where(:user_id => user.id).first_or_create
            end

            respond_to do |format|
                format.json { render_for_api :user, :json => user, :root => :user}
            end
        else

            if email
                connect_user = ConnectUser.where(:email => email).first_or_create
            elsif phone
                connect_user = ConnectUser.where(:phone => phone).first_or_create
            end
            puts "do we now have a connect user from the add user section? #{connect_user}"

            connect_user.update_attributes params[:user]
            project.project_users.where(:connect_user_id => connect_user.id).first_or_create
            company.connect_users << connect_user if company

            if task
                if email
                    connect_user.email_task(task)
                elsif phone
                    connect_user.text_task(task)
                end
            elsif report
                report.report_users.where(:connect_user_id => connect_user.id).first_or_create
            end

            respond_to do |format|
                format.json { render_for_api :user, :json => connect_user, :root => :connect_user}
            end
        end
    end

    def dash
        @project = Project.find params[:id]
        unless @project.checklist.nil?
            respond_to do |format|
                format.json { render_for_api :dashboard, :json => @project}
            end
        else
            render :json => {success: false}
        end
    end

    def archived
        user = User.find params[:user_id]    
        projects = user.project_users.where(:archived => true).map(&:project).compact
     
        if projects
            respond_to do |format|
                format.json { render_for_api :projects, :json => projects.sort_by{|p| p.name.downcase}, :root => :projects}
            end
        else
            render :json => {success: false}
        end
    end

    def archive
        user = User.find params[:user_id]
        project = Project.find params[:id]
        if project.core
            render :json => {success: true}
        elsif  user.admin || user.company_admin || user.uber_admin
            project_user = project.project_users.where(:user_id => user).first

            if project_user
                project_user.update_attribute :archived, true
                render :json => {success: true}
            else
                render :json => {success: false}
            end
        else
            respond_to do |format|
                format.json { render_for_api :login, :json => user, :root => :user}
            end
        end
    end

    def unarchive
        @user = User.find params[:user_id]
        @project = Project.find params[:id]
        project_user = @project.project_users.where(:user_id => @user).first

        if project_user
            project_user.update_attribute :archived, false
            render :json => {success: true}
        else
            render :json => {success: false}
        end
    end

end
