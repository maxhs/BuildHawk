class Alternate < ActiveRecord::Base
	attr_accessible :user_id, :email, :phone
	belongs_to :user
end
