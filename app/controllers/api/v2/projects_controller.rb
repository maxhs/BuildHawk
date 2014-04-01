class Api::V2::ProjectsController < Api::V2::ApiController

    def index
    	user = User.find params[:user_id]
    	projects = user.projects.where(:project_group_id => nil).order("name ASC")
        projects += Project.where(:core => true).flatten
        
        groups = user.projects.where("project_group_id IS NOT NULL").map(&:project_group_id).uniq
        if groups
            groups.each do |g|
                projects << ProjectGroup.find(g).projects.first
            end 
        end
        
        if projects
        	respond_to do |format|
            	format.json { render_for_api :projects, :json => projects, :root => :projects}
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

end
