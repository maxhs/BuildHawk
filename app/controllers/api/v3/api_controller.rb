class Api::V3::ApiController < ApplicationController
    #http_basic_authenticate_with name: "buildhawk_mobile", password: "aca344dc4b27b82f994094d8c9bab0af"#, except: :index
  	skip_before_filter :verify_authenticity_token
  	before_filter :verify_mobile_token

  	private
  	
  	def verify_mobile_token
        #puts "Request: #{request.env['HTTP_DEVICE_TYPE']}"
        @device_type = request.env['HTTP_DEVICE_TYPE'].to_i
        puts "Device type: #{@device_type}"
  		if params[:device_type].present? && params[:mobile_token].present? 
            @user = User.where(mobile_token: params[:mobile_token]).first
  			if @user
                puts "Mobile token verified"
                return true 
  			else
                puts "Could not verify mobile token"
                return false
            end
  		else
  			return true
  		end
  	end

end