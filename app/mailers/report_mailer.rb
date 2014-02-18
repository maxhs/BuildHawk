class ReportMailer < ActionMailer::Base
  	layout "report_mailer"

  	def report(report,recipient)
  		@recipient = recipient
  	  	@report = report
  		mail(
      		:subject => "#{report.project.name} - #{report.created_date}",
      		:to      => recipient.email,
      		:from 	 => "reports@buildhawk.com",
      		:tag     => 'Report'
    	)
  	end
end
