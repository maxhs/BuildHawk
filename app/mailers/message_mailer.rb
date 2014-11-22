class MessageMailer < ActionMailer::Base
  	layout "standard_mailer"

  	def send_message(message, user)
  		@message = message
  		@user = user
  		mail(
      		:subject => "#{message.body[0..15]}...",
      		:to      => user.email,
      		:from 	 => "support@buildhawk.com",
      		:tag     => 'Message'
    	)
  	end
end
