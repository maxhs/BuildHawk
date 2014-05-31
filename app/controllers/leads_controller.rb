class LeadsController < ApplicationController
	def create
		lead = Lead.create params[:lead]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to root_url
		end
	end
end
