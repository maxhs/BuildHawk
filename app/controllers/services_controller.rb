class ServicesController < ApplicationController
	skip_before_filter :verify_authenticity_token

	def support
		render json: {success: true}
	end

	def tasks
		events = JSON.parse params[:mandrill_events]
		events.each do |e|
			puts "e text:#{e['msg']['text']}"
		end
		
		render json: {success: true}
	end

	def reports
		render json: {success: true}
	end

	def checklists
		render json: {success: true}
	end

end