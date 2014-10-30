class Api::V3::ApiController < ApplicationController
  	skip_before_filter :verify_authenticity_token
  	before_filter :verify_mobile_token

  	private
  	
  	def verify_mobile_token
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
  			puts "No mobile token params"
  			return true
  		end
  	end

end