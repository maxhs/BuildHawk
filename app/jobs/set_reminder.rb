module SetReminder
	@queue = :set_reminder

	def self.perform(reminder_id)
		reminder = Reminder.find reminder_id
		if reminder.user && reminder.user.email_permissions
			ReminderMailer.checklist_reminder(reminder_id).deliver
		end
	end
end