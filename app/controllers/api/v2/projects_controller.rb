class Api::V2::ProjectsController < Api::V2::ApiController

    def index
        @user = User.find params[:user_id]
        projects = @user.project_users.where("archived = ? and core = ? and project_group_id IS NULL",false,false).map(&:project).compact.sort_by{|p| p.name.downcase}
        if projects
        	respond_to do |format|
            	format.json { render_for_api :projects, :json => projects, :root => :projects}
          	end
        else
            render :json => {success: false}
        end
    end

    def groups
        @user = User.find params[:user_id]
        group_ids = @user.project_users.where("project_group_id IS NOT NULL").map(&:project_group_id).uniq
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

    def dashboard
        @user = User.find params[:user_id]
        projects = @user.project_users.where("archived = ? and core = ?",false,false).map(&:project).compact
        if @project.checklist
            respond_to do |format|
                format.json { render_for_api :dashboard, :json => projects, root: :projects}
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

    def add_user
        project = Project.find params[:id]
        company = project.companies.where(:id => params[:company_id]).first
        puts "found company: #{company.name}" if company
        task = WorklistItem.find params[:task_id] if params[:task_id] && params[:task_id] != 0
        report = Report.find params[:report_id] if !task and params[:report_id]
        if params[:user][:email]
            user = User.where(:email => params[:user][:email]).first
            if user
                #existing user, notify them by email
                project.project_users.where(:user_id => user.id).first_or_create
            else
                alternate = Alternate.where(:email => params[:user][:email]).first
                if alternate
                    user = alternate.user
                    project.project_users.where(:user_id => user.id).first_or_create
                end
            end
        
            if user
                respond_to do |format|
                    format.json { render_for_api :user, :json => user, :root => :user}
                end
            elsif task
                puts "couldn't find user for task assignment: #{params[:user]}"
                connect_user = task.connect_users.create params[:user]
                respond_to do |format|
                    format.json { render_for_api :user, :json => connect_user, :root => :connect_user}
                end
            elsif report
                puts "couldn't find user for report: #{params[:user]}"
                connect_user = report.connect_users.create params[:user]
                respond_to do |format|
                    format.json { render_for_api :user, :json => connect_user, :root => :connect_user}
                end
            else
                render json: {success: "No task"}
            end
        elsif params[:user][:phone]
            user = User.where(:phone => params[:user][:phone]).first
            if user
                #existing user
                project.project_users.where(:user_id => user.id).first_or_create
            else
                alternate = Alternate.where(:phone => params[:user][:phone]).first
                if alternate
                    user = alternate.user
                    user.text_task(task) if task
                    project.project_users.where(:user_id => user.id).first_or_create
                end
            end
        
            if user
                respond_to do |format|
                    format.json { render_for_api :user, :json => user, :root => :user}
                end
            elsif task
                connect_user = task.connect_users.create params[:user]
                respond_to do |format|
                    format.json { render_for_api :user, :json => connect_user, :root => :connect_user}
                end
            elsif report
                puts "couldn't find user for report: #{params[:user]}"
                connect_user = report.connect_users.create params[:user]
                respond_to do |format|
                    format.json { render_for_api :user, :json => connect_user, :root => :connect_user}
                end
            else
                render json: {success: "No task"}
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
        #if user.admin || user.company_admin
        #    @projects = user.company.projects.where(:archived => true)
        #else
            @projects = user.project_users.where(:archived => true).map(&:project).compact
        #end
       
        if @projects
            respond_to do |format|
                format.json { render_for_api :projects, :json => @projects.sort_by{|p| p.name.downcase}, :root => :projects}
            end
        else
            render :json => {success: false}
        end
    end

    def archive
        @user = User.find params[:user_id]
        if @user.admin || @user.company_admin || @user.uber_admin
            @project = Project.find params[:id]
            project_user = @project.project_users.where(:user_id => @user).first

            if project_user
                project_user.update_attribute :archived, true
                render :json => {success: true}
            else
                render :json => {success: false}
            end
        else
            respond_to do |format|
                format.json { render_for_api :login, :json => @user, :root => :user}
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

    private

    def find_projects
        @user = User.find params[:user_id]
        @projects = @user.project_users.where(:archived => false).map{|u| u.project if u.project.project_group_id == nil}.compact

        @archived_projects = @user.project_users.where(:archived => true).map(&:project)
        new_projects = []
        Project.where(:core => true).flatten.each do |c|
            new_projects << c unless @archived_projects.include?(c)
        end

        @projects += new_projects
        @projects = @projects.uniq.sort_by{|p| p.name.downcase}
    end
end
