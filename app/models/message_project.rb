class MessageProject < ActiveRecord::Base
	attr_accessible :message_id, :project_id

	belongs_to :message
	belongs_to :project

end
