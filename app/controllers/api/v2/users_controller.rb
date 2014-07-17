class Api::V2::UsersController < Api::V2::ApiController
	before_filter :find_user

	def show
		respond_to do |format|
        	format.json { render_for_api :login, :json => @user, :root => :user}
      	end
	end

	def connect
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

	def update
		@user.update_attributes params[:user]
		respond_to do |format|
        	format.json { render_for_api :user, :json => @user, :root => :user}
      	end
	end

	def add_alternate
		if params[:email]
			alternate = @user.alternates.create :email => params[:email]
		elsif params[:phone]
			alternate = @user.alternates.create :email => params[:email]
		end

    	if alternate.save
    		respond_to do |format|
                format.json { render_for_api :user, :json => alternate, :root => :alternate}
            end
    	else
    		render json: {success: false}
    	end
	end

	def delete_alternate
		if params[:email]
			alternate = @user.alternates.where(:email => params[:email]).first
		elsif params[:phone]
			alternate = @user.alternates.where(:email => params[:email]).first
		elsif params[:alternate_id]
			alternate = Alternate.find params[:alternate_id]
		end

		if alternate && alternate.destroy
			render json: {success: true}
		else
			render json: {failure: true}
		end
	end

	private

	def find_user
		@user = User.find params[:id] if params[:id]
	end

end
