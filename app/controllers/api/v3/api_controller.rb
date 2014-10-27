class Api::V3::ApiController < ApplicationController
  	skip_before_filter :verify_authenticity_token
  	#before_filter :verify_mobile_token

  	private
  	
  	def verify_mobile_token
  		@user = User.where(mobile_token: params[:mobile_token]).first
  		unless params[:device_type].present? && params[:mobile_token].present? && @user 
  			puts "Couldn't verify mobile token"
  			return false
  		else
  			puts "Mobile token verified"
  			return true
  		end
  	end

end