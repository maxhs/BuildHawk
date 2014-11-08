class Api::V3::UsersController < Api::V3::ApiController
	before_filter :find_user

	def show
		respond_to do |format|
        	format.json { render_for_api :login, :json => @user, :root => :user}
      	end
	end

	def update
		if params[:user][:phone]
			params[:user][:phone] = @user.clean_phone(params[:user][:phone])
		else
			params[:user][:phone] = nil
		end
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

	def remove_push_token
		render json: {success: @user.remove_push_tokens_except(@device_type, params[:token])} if @device_type
	end

	private

	def find_user
		@user = User.find params[:id] if params[:id]
	end

end
