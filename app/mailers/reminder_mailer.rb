class ReminderMailer < ActionMailer::Base
    layout "list_mailer"

    def checklist_reminder(reminder_id)
      	@recipient = User.where(:email => recipient_email).first
      	@reminder = Reminder.find reminder_id
      	@logo_url = @company.image.url(:small) if @company.image_file_name
      	@checklist_item = reminder.checklist_item
      	@project = @checklist_item.checklist.project
      	mail(
         	:subject => "Reminder: #{@checklist_item.body[0..20]}...",
          	:to      => @recipient.email,
          	:from    => "support@buildhawk.com",
          	:tag     => 'Checklist Item Reminder'
      	)
    end
end
