class ReportMailer < ActionMailer::Base
  	layout "report_mailer"

  	def report(report,recipient)
  		@recipient = recipient
  	  @report = report
      @company = report.project.company
  		mail(
      		:subject  => "#{report.project.name} - #{report.created_date}",
      		:to       => recipient.email,
      		:from 	  => "reports@buildhawk.com",
          :reply_to => "reports@inbound.buildhawk.com",
      		:tag      => 'Report'
    	)
  	end
end
