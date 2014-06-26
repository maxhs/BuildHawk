module Reminder
	@queue = :reminder

	def self.perform(reminder_id)
		reminder = Reminder.where(:id => reminder_id).last
		puts "Enqueuing a reminder: #{reminder}"
		#if reminder.user && reminder.user.email_permissions
			ReminderMailer.checklist_reminder(reminder_id).deliver
		#end
	end
end