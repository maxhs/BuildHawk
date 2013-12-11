class Comment < ActiveRecord::Base
	attr_accessible :body, :user_id, :report_id
  	belongs_to :user
  	belongs_to :report
  	belongs_to :checklist_item
  	belongs_to :punchlist_item
  	has_many :photos

  	acts_as_api

  	api_accessible :user do |t|

  	end

  	api_accessible :projects do |t|

  	end

  	api_accessible :dashboard do |t|

  	end
end
