class PunchlistItemMailer < ActionMailer::Base
  	layout "item_mailer"

  	def punchlist_item(punchlist_item,recipient)
  		@recipient = recipient
  	  	@punchlist_item = punchlist_item
  		mail(
      		:subject => "#{punchlist_item.punchlist.project.name} - #{punchlist_item.body}",
      		:to      => recipient.email,
      		:from 	 => "support@buildhawk.com",
      		:tag     => 'Worklist Item'
    	)
  	end
end
