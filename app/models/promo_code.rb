class PromoCode < ActiveRecord::Base
	attr_accessible :user_id, :code, :percentage, :days, :use_count
	belongs_to :user
	
	def increment_count
		self.use_count++
		self.save
	end
end