class Charge < ActiveRecord::Base
	attr_accessible :company_id, :company, :paid, :promo_code, :description
  	belongs_to :company

  	def amount
  		company.projects.count * 10
  	end
end
