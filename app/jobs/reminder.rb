module Reminder
	@queue = :reminder

	def self.perform(reminder_id)
		reminder = Reminder.find reminder_id
		puts "Enqueuing a reminder: #{reminder}"
		#if reminder.user && reminder.user.email_permissions
			ReminderMailer.checklist_reminder(reminder_id).deliver
		#end
	end
end