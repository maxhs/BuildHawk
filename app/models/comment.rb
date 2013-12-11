class Comment < ActiveRecord::Base
	attr_accessible :body, :user_id, :report_id
  	belongs_to :user
  	belongs_to :report
  	has_many :photos

  	acts_as_api

  	api_accessible :user do |t|

  	end

  	api_accessible :projects do |t|

  	end
end
