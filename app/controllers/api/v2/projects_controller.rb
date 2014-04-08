class Api::V2::ProjectsController < Api::V2::ApiController

    def index
        #find_projects
        @user = User.find params[:user_id]
        @projects = @user.project_users.where(:archived => false, project_group_id => nil, :core => true).map(&:project).compact 
        
        groups = @user.project_users.where("project_group_id IS NOT NULL").map(&:project_group_id).uniq
        if groups
            groups.each do |g|
                @projects << ProjectGroup.find(g).projects.first
            end 
        end
        
        if @projects
        	respond_to do |format|
            	format.json { render_for_api :projects, :json => @projects, :root => :projects}
          	end
        else
            render :json => {success: false}
        end
    end

    def show
    	@project = Project.find params[:id]
    	respond_to do |format|
        	format.json { render_for_api :projects, :json => @project}
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

    def archive
        @user = User.find params[:user_id]
        @project = Project.find params[:id]
        @user.archived_projects.create :project_id => params[:id]
        project_user = @project.project_users.where(:user_id => @user).first

        if project_user
            project_user.update_attribute :archived, true
            render :json => {success: true}
        else
            render :json => {success: false}
        end
    end

    private

    def find_projects
        @user = User.find params[:user_id]
        @projects = @user.project_users.where(:archived => false).map{|u| u.project if u.project.project_group_id == nil}.compact

        archived = @user.archived_projects
        new_projects = []
        Project.where(:core => true).flatten.each do |c|
            new_projects << c unless archived.include?(c)
        end

        @projects += new_projects
        @projects = @projects.uniq
        @projects = @projects.sort_by{|p| p.name.downcase}
    end
end
