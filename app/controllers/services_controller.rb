class ServicesController < ApplicationController
	skip_before_filter :verify_authenticity_token
	include TasksHelper

	def support
		render json: {success: true}
	end

	def tasks
		events = JSON.parse params[:mandrill_events]
		events.each do |e|
			text = e['msg']['text'].partition('Write ABOVE THIS LINE to reply').first.html_safe
			cleaned_text = cleanText(text)
			puts "e text:#{cleaned_text}"
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