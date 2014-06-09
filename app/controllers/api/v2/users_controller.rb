class Api::V2::UsersController < Api::V2::ApiController
	before_filter :find_user

	def show
		
	end

	def connect_items
		items = WorklistItem.where(:assignee_id => @user.id)
		respond_to do |format|
        	format.json { render_for_api :worklist, :json => items, :root => :worklist_items}
      	end
	end

	private

	def find_user
		@user = User.find params[:id] if params[:id]
	end

end
