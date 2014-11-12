class ReminderMailer < ActionMailer::Base
    layout "list_mailer"

    def checklist_reminder(reminder_id)
      	@reminder = Reminder.find reminder_id
      	@recipient = @reminder.user
      	@checklist_item = @reminder.checklist_item
      	@project = @checklist_item.checklist.project
      	@company = @project.company
      	@logo_url = @company.image.url(:small) if @company.image_file_name
      	mail(
         	:subject => "Reminder: #{@checklist_item.body[0..20]}...",
          	:to      => @recipient.email,
          	:from    => "support@buildhawk.com",
          	:tag     => 'Checklist Item Reminder',
            :reply_to => "reminders@inbound.buildhawk.com"
      	)
    end
end
