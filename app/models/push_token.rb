class PushToken < ActiveRecord::Base
	attr_accessible :token, :user_id
  	belongs_to :user
end