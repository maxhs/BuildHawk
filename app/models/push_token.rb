class PushToken < ActiveRecord::Base
	attr_accessible :token, :user_id, :device_type
  	belongs_to :user
end