class Api::V3::ProjectsController < Api::V3::ApiController

    def index
        user = User.find params[:user_id]
        user.notifications.where(:read => false).each do |n| n.update_attribute :read, true end

        if user.any_admin?
            projects = user.company.project_users.where("hidden = ? and core = ? and project_group_id IS NULL",false,false).map{|p| p.project if p.project.company_id == user.company_id}.compact.uniq.sort_by(&:order_index)
        else
            projects = user.project_users.where("hidden = ? and core = ? and project_group_id IS NULL",false,false).map{|p| p.project if p.project.company_id == user.company_id}.compact.sort_by(&:order_index)
        end

        if projects
            respond_to do |format|
                format.json { render_for_api :visible_projects, :json => projects, :root => :projects}
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
            format.json { render_for_api :v3_details, :json => project, :root => :project}
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
        task = Task.find params[:task_id] if params[:task_id] && params[:task_id] != 0
        report = Report.find params[:report_id] if params[:report_id] && params[:report_id] != 0

        if params[:user][:company_name]
            company_name = "#{params[:user][:company_name]}"
            company = Company.where("name ILIKE ?",company_name).first
            company = Company.create :name => company_name unless company
            params[:user][:company_id] = company.id

            ## create a new project subcontractor object for the project
            project.project_subs.create :company_id => company.id

            ## create a new company subcontractor object for the company that owns the project
            project.company.company_subs.where(:subcontractor_id => company.id).first_or_create 

            params[:user].delete(:company_name)
        end

        email = params[:user][:email].strip if params[:user][:email]
        puts "do we have an email? #{email}"
        phone = params[:user][:phone].gsub(/[^0-9a-z ]/i, '').gsub(/\s+/,'') if params[:user][:phone]
        puts "do we have a phone? #{phone}"

        user = User.where(:email => email).first
        user = User.where(:phone => phone).first unless user

        unless user
            alternate = Alternate.where(:email => email).first if email
            alternate = Alternate.where(:phone => phone).first if phone && !alternate
            user = alternate.user if alternate
        end

        unless user
            ## still no user? This means they're a "connect user". Creating a new user here will create an inactive user by default.
            if email
                user = User.where(:email => email).first_or_create
            elsif phone
                user = User.where(:phone => phone).first_or_create
            end
        end

        ## update the user and ensure they're attached to the project
        user.update_attributes params[:user]
        project.project_users.where(:user_id => user.id).first_or_create
        project.project_subs.where(:company_id => user.company_id).first_or_create if user.company_id

        ## notify the user
        if task
            if email && user.email_permissions
                user.email_task(task)
            elsif phone && user.text_permissions
                user.text_task(task)
            end
            task.update_attribute :assignee_id, user.id
        elsif report
            report.report_users.where(:user_id => user.id).first_or_create
        end

        respond_to do |format|
            format.json { render_for_api :user, :json => user, :root => :user}
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

    def hidden
        user = User.find params[:user_id]    
        projects = user.project_users.where(:hidden => true).map(&:project).compact
     
        if projects
            respond_to do |format|
                format.json { render_for_api :projects, :json => projects.sort_by{|p| p.name.downcase}, :root => :projects}
            end
        else
            render :json => {success: false}
        end
    end

    def hide
        user = User.find params[:user_id]
        project = Project.find params[:id]
        if project.core
            render :json => {success: true}
        else

            project_user = project.project_users.where(:user_id => user).first
            if project_user
                project_user.update_attribute :hidden, true
                render :json => {success: true}
            else
                render :json => {success: false}
            end
        end
    end

    def activate
        @user = User.find params[:user_id]
        @project = Project.find params[:id]
        project_user = @project.project_users.where(:user_id => @user).first

        if project_user
            project_user.update_attribute :hidden, false
            render :json => {success: true}
        else
            render :json => {success: false}
        end
    end

end
