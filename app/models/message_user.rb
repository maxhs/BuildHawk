class MessageUser < ActiveRecord::Base
	attr_accessible :message_id, :user_id, :sent, :read, :archived
	
	belongs_to :message
	belongs_to :user

	after_create :notify

	def notify
		puts "Just created a message user: #{user.full_name}"
		MessageMailer.send_message(message,user).deliver if user.email_permissions
		self.update_column :sent, true
	end
end