class ServicesController < ApplicationController

	def support
		puts "support webhook from mandrill: #{parameters}"
	end

	def tasks
		puts "tasks webhooks from mandrill: #{parameters}"
	end

	def reports
		puts "reports webhooks from mandrill: #{parameters}"
	end

end