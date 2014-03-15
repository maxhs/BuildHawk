class Api::V1::ProjectsController < Api::V1::ApiController

    def index
    	@user = User.find params[:user_id]
    	projects = @user.projects
    	respond_to do |format|
        	format.json { render_for_api :projects, :json => projects, :root => :projects}
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

end
