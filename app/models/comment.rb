class Comment < ActiveRecord::Base
	attr_accessible :body, :user_id, :report_id
  	belongs_to :user
  	belongs_to :report
  	has_many :photos
end
