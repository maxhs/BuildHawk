class PushToken < ActiveRecord::Base
	attr_accessible :token, :user_id, :device_type
  	belongs_to :user
  	## 1 for iphone, ## 2 for ipad, ## 3 for android
end