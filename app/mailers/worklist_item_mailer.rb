class WorklistItemMailer < ActionMailer::Base
  	layout "list_mailer"

  	def worklist_item(worklist_item,recipient)
      #the recipient could be a user or a connect user. be careful.
  		@recipient = recipient
  	  @worklist_item = worklist_item
  		mail(
      		:subject => "#{worklist_item.punchlist.project.name} - #{worklist_item.body}",
      		:to      => recipient.email,
      		:from 	 => "support@buildhawk.com",
      		:tag     => 'Worklist Item'
    	)
  	end
end
