class ReminderMailer < ActionMailer::Base
    layout "list_mailer"

    def checklist_reminder(reminder_id)
      	@reminder = Reminder.find reminder_id
      	@recipient = @reminder.user
      	@checklist_item = reminder.checklist_item
      	@project = @checklist_item.checklist.project
      	@logo_url = @project.company.image.url(:small) if @project.company.image_file_name
      	mail(
         	:subject => "Reminder: #{@checklist_item.body[0..20]}...",
          	:to      => @recipient.email,
          	:from    => "support@buildhawk.com",
          	:tag     => 'Checklist Item Reminder'
      	)
    end
end
