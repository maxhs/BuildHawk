class PunchlistItem < ActiveRecord::Base
	attr_accessible :body, :assignee_id, :assignee, :project_id, :project, :location, :assignee, :photos

	belongs_to :project
	belongs_to :assignee, :class_name => "User"

	has_many :photos
end
