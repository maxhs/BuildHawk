class HomeController < ApplicationController

	def index
		if user_signed_in?

		else
			render :splash
		end
	end
end
