class Api::V2::UsersController < Api::V2::ApiController
	before_filter :find_user

	def show
		
	end

	def worklist_connect
		worklists = WorklistItem.where(:assignee_id => @user.id).map(&:worklist).compact
		respond_to do |format|
        	format.json { render_for_api :worklist, :json => worklists, :root => :worklists}
      	end
	end

	private

	def find_user
		@user = User.find params[:id] if params[:id]
	end

end
