class TasklistMailer < ActionMailer::Base
  	layout "list_mailer"

  	def export(recipient, task_array)
  		@recipient = recipient
        @connect_user = @recipient if @recipient && !@recipient.active
  		@task_array = task_array
        @tasklist = task_array[0].tasklist
        @project = @tasklist.project
  		mail(
      		:subject  => "#{@project.name} - Tasks Assigned to You",
      		:to       => @recipient.email,
      		:from     => "BuildHawk Tasks <support@buildhawk.com>",
            :reply_to => "tasks@inbound.buildhawk.com",
      		:tag      => 'Task Export'
    	)
  	end
end
