class Api::V2::ConnectController < Api::V2::ApiController

	before_filter :find_user

    def index
    	project = Project.find params[:project_id] if params[:project_id]
		if @user
			if project
				items = WorklistItem.where(:assignee_id => @user.id).map{|t| t if t.worklist.project.id = project.id}.compact
			else
				items = WorklistItem.where(:assignee_id => @user.id).map{|t| t if t.worklist.project.company.id != @user.company.id}.compact
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