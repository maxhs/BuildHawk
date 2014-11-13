class ServicesController < ApplicationController
	skip_before_filter :verify_authenticity_token
	
	def support
		puts "support webhook from mandrill: #{parameters}"
	end

	def tasks
		puts "tasks webhooks from mandrill: #{parameters}"
	end

	def reports
		puts "reports webhooks from mandrill: #{parameters}"
	end

	def checklists
		puts "checklists webhooks from mandrill: #{parameters}"
	end

end