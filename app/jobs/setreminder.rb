module SetReminder
	@queue = :set_reminder_queue

	def self.perform(reminder_id)
		time = Time.zone.now.strftime("%l:00 %P").strip
		reminder = Reminder.find reminder_id
		if reminder.user && reminder.user.email_permissions
			ReminderMailer.checklist_reminder(reminder_id).deliver
		end
	end
end