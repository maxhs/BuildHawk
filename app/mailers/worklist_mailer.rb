class WorklistMailer < ActionMailer::Base
  	layout "list_mailer"

  	def export(recipient_email, item_array, project)
  		@recipient = User.where(:email => recipient_email).first
  		@recipient = Sub.where(:email => recipient_email).first unless @recipient
      unless @recipient
        @recipient = ConnectUser.where(:email => recipient_email).first
        @connect_user = @recipient if @recipient
      end
  		@project = project
      @company = @project.company
  		@item_array = item_array
  		mail(
      		:subject => "#{project.name} - Tasks Assigned to You",
      		:to      => recipient_email,
      		:from 	 => "support@buildhawk.com",
      		:tag     => 'Task Export'
    	)
  	end
end
