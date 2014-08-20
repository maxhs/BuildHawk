class TaskAssignee < ActiveRecord::Base
	attr_accessible :user_id, :connect_user_id, :worklist_item_id

	belongs_to :user
	belongs_to :connect_user
	belongs_to :worklist_item
end
