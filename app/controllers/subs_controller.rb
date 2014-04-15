class SubsController < ApplicationController
	before_filter :authenticate_user!
	
	def update
		sub = Sub.find params[:id]
		sub.update_attributes params[:sub]
	end
end
