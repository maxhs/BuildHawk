class PromoCode < ActiveRecord::Base
	attr_accessible :user_id, :code, :percentage, :days, :use_count, :company_id
	belongs_to :user
	belongs_to :company
	
	def increment_count
		self.use_count++
		self.save
	end
end