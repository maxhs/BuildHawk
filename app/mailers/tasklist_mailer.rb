class TasklistMailer < ActionMailer::Base
  	layout "list_mailer"

  	def export(recipient_email, task_array, project)
  		@recipient = User.where(:email => recipient_email).first
        @connect_user = @recipient if @recipient && !@recipient.active
  		@project = project
  		@task_array = task_array
  		mail(
      		:subject  => "#{project.name} - Tasks Assigned to You",
      		:to       => recipient_email,
      		:from     => "support@buildhawk.com",
            :reply_to => "tasks@inbound.buildhawk.com",
      		:tag      => 'Task Export'
    	)
  	end
end
