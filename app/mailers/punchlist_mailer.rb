class PunchlistMailer < ActionMailer::Base
  	layout "item_mailer"

  	def export(recipient, item_array)
  		@recipient = recipient
  		mail(
      		:subject => "Worklist Items",
      		:to      => recipient.email,
      		:from 	 => "support@buildhawk.com",
      		:tag     => 'Worklist Export'
    	)
  	end
end
