class Api::V3::SessionsController < Api::V3::ApiController

    def create
        if params[:user].present?
          if params[:user][:device_token]
            device_token = params[:user][:device_token]
            params[:user].delete(:device_token)
          end
          if params[:user][:device_type]
            device_type = params[:user][:device_type]
            params[:user].delete(:device_type)
          end
        end

        device_token = params[:device_token] if params[:device_token]
        device_type = params[:device_type] if params[:device_type]

        if params[:user].present?
            email = params[:user][:email]
        elsif params[:email]
            email = params[:email]
        end

        if params[:user].present?
            password = params[:user][:password]
        elsif params[:password]
            password = params[:password]
        end

  		@user = User.find_for_database_authentication email: email if email
  		return invalid_login_attempt unless @user

  		if @user.valid_password? password
            if device_token && device_type
  			    @user.push_tokens.where(:token => device_token, :device_type => device_type).first_or_create
            elsif device_token
                @user.push_tokens.where(:token => device_token).first_or_create
            end
  			
            respond_to do |format|
  		  		format.json { render_for_api :login, :json => @user, :root => :user}
  			end
  		else
  			render text: 'Incorrect password', status: 401
        end
    end

    def forgot_password
        if params[:email]
            user = User.find_by_email params[:email]
            if user
                user.send_reset_password_instructions
                render :json=>{"user"=>user}
            else 
                render :json=>{ failure: true }
            end
        end
    end 

  def destroy
    user = User.find params[:user_id]
    user.update_attribute :authentication_token, nil
    render json: {success: true}
  end

  private

  def invalid_login_attempt
    render text: 'No email', status: 401
  end
end
