class HomeController < ApplicationController

	def index
		if user_signed_in?
			redirect_to projects_path
		else
			@lead = Lead.new
			render :splash
		end
	end

	def show
		if user_signed_in?
			redirect_to projects_path
		else
			render :index
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

	def privacy
		
	end

	def terms

	end
end
