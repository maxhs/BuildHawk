class MessageMailer < ActionMailer::Base
  	layout "standard_mailer"
  	include ApplicationHelper

  	def send_message(message, user)
  		@message = message
  		@user = user
  		@timestamp = parse_datetime(message.created_at)
  		mail(
      		:subject => "#{message.body[0..15]}...",
      		:to      => user.email,
      		:from 	 => "BuildHawk Message <support@buildhawk.com>",
      		:tag     => 'Message'
    	)
  	end
end
