class Report < ActiveRecord::Base
	attr_accessible :title, :type, :body, :user_id, :project_id
  	belongs_to :user
  	belongs_to :project
  	has_many :comments
end
