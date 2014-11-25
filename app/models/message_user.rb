class MessageUser < ActiveRecord::Base
	attr_accessible :message_id, :user_id, :sent, :read, :archived
	
	belongs_to :message
	belongs_to :user

	after_create :notify

	def notify
		if user.email_permissions
			MessageMailer.send_message(message,user).deliver
			self.update_column :sent, true
		end

		user.notifications.create(
			message_id: id,
			body: "#{message.author.full_name} just sent you a message: #{message.body}."
		)
	end
end