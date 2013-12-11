class Api::V1::ChecklistsController < Api::V1::ApiController

    def index
    	@user = User.find params[:user_id]
    	projects = @user.projects
    	respond_to do |format|
        	format.json { render_for_api :projects, :json => projects, :root => :projects}
      	end
    end

    def show
    	@checklist = Checklist.find params[:id]
    	respond_to do |format|
        	format.json { render_for_api :checklist, :json => @checklist, :root => :checklist}
      	end
    end

end
