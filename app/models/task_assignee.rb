class TaskAssignee < ActiveRecord::Base
	attr_accessible :user_id, :connect_user_id, :task_id

	belongs_to :user
	belongs_to :connect_user
	belongs_to :task
end
