class PromoCode < ActiveRecord::Base
	attr_accessible :user_id, :code, :percentage, :days
	belongs_to :user

end