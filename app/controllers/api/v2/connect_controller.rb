class Api::V2::ConnectController < Api::V2::ApiController

	before_filter :find_user

    def index
    	project = Project.find params[:project_id] if params[:project_id]
		if @user
			if project
				items = @user.connect_items(project)
			else
				items = @user.connect_items(nil)
			end
			respond_to do |format|
	        	format.json { render_for_api :connect, :json => items, :root => :worklist_items}
	      	end
		else
      		render json: {success: false}
      	end
	end

	private

	def find_user
		@user = User.find params[:user_id] if params[:user_id]
	end

end