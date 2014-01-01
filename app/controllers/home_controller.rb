class HomeController < ApplicationController

	def index
		if user_signed_in?
			redirect_to projects_path
		else
			@company = Company.new
			render :splash
		end
	end

	def about
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :about
		end
	end
end
