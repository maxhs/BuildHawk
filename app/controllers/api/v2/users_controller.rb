class Api::V2::UsersController < Api::V2::ApiController
	before_filter :find_user

	def show
		
	end

	def worklist_connect
		items = WorklistItem.where(:assignee_id => @user.id)
		respond_to do |format|
        	format.json { render_for_api :worklist, :json => items, :root => :worklist_items}
      	end
	end

	def update
		@user.update_attributes params[:user]
		respond_to do |format|
        	format.json { render_for_api :user, :json => @user, :root => :user}
      	end
	end

	private

	def find_user
		@user = User.find params[:id] if params[:id]
	end

end
