class MessageUser < ActiveRecord::Base
	attr_accessible :message_id, :user_id, :sent, :read, :archived
	
	belongs_to :message
	belongs_to :user
end