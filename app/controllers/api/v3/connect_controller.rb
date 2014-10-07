class Api::V3::ConnectController < Api::V3::ApiController

	before_filter :find_user

    def index
    	project = Project.find params[:project_id] if params[:project_id]
		if @user
			if project
				tasks = @user.connect_tasks(project)
			else
				tasks = @user.connect_tasks(nil)
			end
			respond_to do |format|
	        	format.json { render_for_api :connect, :json => tasks, :root => :tasks}
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