class LeadMailer < ActionMailer::Base
  	layout "standard_mailer"

  	def email_will(lead)
  		@lead = lead
  		if lead.company_name
  			subject = "BuildHawk - new lead: #{lead.company_name}"
  		elsif 
  			subject = "BuildHawk - new lead: #{lead.name}"
  		else
  			subject = "BuildHawk - new lead"
  		end
  		mail(
      		:subject => subject,
      		:to      => ["will@buildhawk.com","max@ristrettolabs.com"],
      		:from 	 => "support@buildhawk.com",
      		:tag     => 'Lead'
    	)
  	end
end
