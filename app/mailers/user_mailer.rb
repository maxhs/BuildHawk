class UserMailer < ActionMailer::Base
	layout "list_mailer"
	def welcome(user)
		@user = user
		mail(
	  		:subject => "Welcome to BuildHawk!",
	  		:to      => user.email,
	  		:from    => "support@buildhawk.com",
	  		:tag     => 'Welcome'
		)
	end
end
