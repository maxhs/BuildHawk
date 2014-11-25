class ServicesController < ApplicationController
	skip_before_filter :verify_authenticity_token

	def support
		render json: {success: true}
	end

	def tasks
		events = JSON.parse params[:mandrill_events]
		events.each do |e|
			text = e['msg']['text'].partition('Write ABOVE THIS LINE to reply').first.html_safe
			puts "e text:#{text.partition('\n\nOn ').first.html_safe}"
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