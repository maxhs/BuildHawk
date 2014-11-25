class Api::V3::ProjectsController < Api::V3::ApiController

    def index
        user = User.find params[:user_id]
        user.notifications.where(read: false).each do |n| n.update_attribute :read, true end

        projects = user.project_users.where("hidden = ? and core = ? and project_group_id IS NULL",false,false).map{|p| p.project if p.project.company_id == user.company_id}.compact.sort_by(&:order_index)
        projects += user.company.projects.map{|p| p unless user.hidden_project_ids.include?(p.id)}.compact if user.any_admin?
           
        if projects
            respond_to do |format|
                format.json { render_for_api :projects, json: projects.uniq, root: :projects}
            end
        else
            render json: {success: false}
        end
    end

    def demo
        projects = Project.where(core: true)
        if params[:user_id]
            projects = projects.map{|project| project unless ProjectUser.where(project_id: project.id, user_id: params[:user_id].first.hidden)}.compact.uniq
        end
        if projects.count > 0
            respond_to do |format|
                format.json { render_for_api :projects, json: projects, root: :projects}
            end
        else
            render :json => {success: false}
        end
    end

    def show
        project = Project.find params[:id]
        respond_to do |format|
            format.json { render_for_api :v3_details, json: project, root: :project}
        end
    end

    def find_user
        project = Project.find params[:id]
        if params[:user][:email]
            user = User.where(email: params[:user][:email]).first
        elsif params[:user][:phone]
            phone = params[:user][:phone].gsub(/[^0-9a-z ]/i, '').gsub(/\s+/,'')
            puts "Trying to find a user with phone: #{phone}"
            user = User.where(phone: phone).first
        end

        if user
            ## existing user. ensure they're attached to the project
            project.project_users.where(user_id: user.id).first_or_create
            respond_to do |format|
                format.json { render_for_api :user, json: user, root: :user}
            end
        else
            alternate = Alternate.where(email: params[:user][:email]).first
            alternate = Alternate.where(phone: phone).first if phone && !alternate
            if alternate
                user = alternate.user
                project.project_users.where(user_id: user.id).first_or_create
                respond_to do |format|
                    format.json { render_for_api :user, json: user, root: :user}
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
            company = Company.where("name ILIKE ?",company_name).first_or_create
            #company = Company.create name: company_name unless company
            params[:user][:company_id] = company.id

            ## create a new project subcontractor object for the project
            project.project_subs.where(company_id: company.id).first_or_create

            ## create a new company subcontractor object for the company that owns the project
            project.company.company_subs.where(:subcontractor_id => company.id).first_or_create 

            params[:user].delete(:company_name)
        end


        if params[:user][:email]
            email = params[:user][:email].strip 
            user = User.where(:email => email).first
        end
        if params[:user][:phone]
            phone = params[:user][:phone].gsub(/[^0-9a-z ]/i, '').gsub(/\s+/,'') 
            user = User.where(:phone => phone).first if !user && phone && phone.length > 0
        end

        unless user
            if email && email.length > 0
                alternate = Alternate.where(email: email).first
            elsif phone && phone.length > 0
                alternate = Alternate.where(phone: phone).first
            end
            user = alternate.user if alternate
        end

        unless user
            ## still no user? This means they're a "connect user". Creating a new user here will create an inactive user by default.
            if email && email.length > 0
                user = User.where(email: email, company_id: company.id).first_or_create
            elsif phone && phone.length > 0
                user = User.where(phone: phone, company_id: company.id).first_or_create
            end
        end

        ## ensure the user is attached to the project
        project.project_users.where(user_id: user.id).first_or_create
        project.project_subs.where(company_id: user.company_id).first_or_create if user.company_id

        ## notify the user
        if task
            ## ensure the user is actually assigned
            TaskUser.where(task_id: task.id, user_id: user.id).first_or_create
            if email && user.email_permissions
                user.email_task(task)
            elsif phone && user.text_permissions
                user.text_task(task)
            end
        elsif report
            report.report_users.where(user_id: user.id).first_or_create
        end

        if user
            respond_to do |format|
                format.json { render_for_api :user, json: user, :root => :user}
            end
        else 
            render json: {success: false}
        end
    end

    def dash
        project = Project.find params[:id]
        unless project.checklist.nil?
            respond_to do |format|
                format.json { render_for_api :dashboard, json: project}
            end
        else
            render :json => {success: false}
        end
    end

    def hidden
        user = User.find params[:user_id]    
        projects = user.project_users.where(hidden: true).map(&:project).compact
     
        if projects
            respond_to do |format|
                format.json { render_for_api :projects, json: projects.sort_by{|p| p.name.downcase}, :root => :projects}
            end
        else
            render :json => {success: false}
        end
    end

    def hide
        project_user = ProjectUser.where(user_id: params[:user_id], project_id: params[:id]).first
        if project_user
            project_user.update_attribute :hidden, true
            render :json => {success: true}
        else
            render :json => {success: false}
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
