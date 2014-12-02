class HomeController < ApplicationController

	def index
		@lead = Lead.new
	end

	def show	
		render :index
	end

	def about
		redirect_to root_url
		# if request.xhr?
		# 	respond_to do |format|
		# 		format.js
		# 	end
		# else
		# 	render :about
		# end
	end

	def privacy
		
	end

	def terms

	end
end
