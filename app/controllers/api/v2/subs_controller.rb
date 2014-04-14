class SubsController < ApplicationController
	def update
		sub = Sub.find params[:id]
		sub.update_attributes params[:sub]
	end
end
