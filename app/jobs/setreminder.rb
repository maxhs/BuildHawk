module SetReminder
	@queue = :reminder

	def self.perform(reminder_id)
		reminder = Reminder.where(:id => reminder_id).last
		if reminder.user && reminder.user.push_permissions
			reminder.user.notifications.create(
				:checklist_item_id => reminder.checklist_item.id,
				:body => "Checklist reminder: #{reminder.checklist_item.body[0..20]}..."
				:notification_type => "Reminder"
			)
			#ReminderMailer.checklist_reminder(reminder_id).deliver
		end
	end
end