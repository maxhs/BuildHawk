class TasklistMailer < ActionMailer::Base
  	layout "list_mailer"

  	def export(recipient, task_array)
  		@recipient = recipient
        @connect_user = @recipient if @recipient && !@recipient.active
  		@task_array = task_array
        @project = task_array[0].tasklist.project
  		mail(
      		:subject  => "#{@project.name} - Tasks Assigned to You",
      		:to       => @recipient.email,
      		:from     => "support@buildhawk.com",
            :reply_to => "tasks@inbound.buildhawk.com",
      		:tag      => 'Task Export'
    	)
  	end
end
