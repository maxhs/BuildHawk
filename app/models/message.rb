class Message < ActiveRecord::Base
	attr_accessible :user_id, :body

	belongs_to :user
	belongs_to :target_project, :class_name => "Project"
	has_many :users
end
