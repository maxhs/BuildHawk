class BillingMailer < ActionMailer::Base
  	layout "standard_mailer"

  	def monthly_invoice(company)
  		@company = company
  		mail(
      		:subject => subject,
      		:to      => User.where(company_id: company.id, company_admin: true).map(&:email),
      		:from 	 => "support@buildhawk.com",
      		:tag     => 'Lead'
    	)
  	end
end
