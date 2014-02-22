class ChecklistMailer < ActionMailer::Base
  	layout "item_mailer"

  	def checklist_item(checklist_item,project,recipient)
  		@recipient = recipient
  	  	@item = checklist_item
  	  	@project = project
  		mail(
      		:subject => "#{project.name} - #{checklist_item.subcategory.category.name}",
      		:to      => recipient.email,
      		:from 	 => "support@buildhawk.com",
      		:tag     => 'Checklist Item'
    	)
  	end
end
