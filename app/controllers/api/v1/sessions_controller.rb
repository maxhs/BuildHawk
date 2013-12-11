class Api::V1::SessionsController < Api::V1::ApiController

    def create
        device_token = params[:user][:device_token]
		@user = User.find_for_database_authentication email: params[:user][:email]
		return invalid_login_attempt unless @user
		if @user.valid_password? params[:user][:password]
			@user.reset_authentication_token!
			puts "successfully signed in user"
            if device_token
			 @user.apn_registrations.where(:token => device_token).first_or_create
			 puts "updating device token for existing email user"
            end
			respond_to do |format|
		  		format.json { render_for_api :user, :json => @user, :root => :user}
			end
		else
			render json: { message: 'Incorrect password' }, status: 401
        end
    end

  def forgot_password
    if params[:email]
      user = User.find_by_email params[:email]
      if user
        user.reset_password
        render :json=>{"user"=>user}
      else 
        render :json=>{:success=>false}
      end
    end
  end 

  def destroy
    current_user.update_attribute :authentication_token, nil
    respond_with current_user
  end

  private

  def invalid_login_attempt
    render json: { message: 'NO EMAIL' }, status: 401
  end
end
