class LeadsController < ApplicationController
	before_filter :authenticate_user!, :except => :create
	def create
		lead = Lead.create params[:lead]
		if verify_recaptcha
			if request.xhr?
				respond_to do |format|
					format.js
				end
			else
				redirect_to root_url
			end
		else
			puts "did't pass"
			if request.xhr?
				respond_to do |format|
					format.js {render template:"home/recaptcha"}
				end
			else
				redirect_to root_url
			end
		end
	end

	def index
		@leads = Lead.all
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :index
		end
	end
end
