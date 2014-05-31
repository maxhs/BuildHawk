class Lead < ActiveRecord::Base
	attr_accessible :name, :company_name, :full_name, :email, :phone_number

	after_create :email_will

	def email_will
		LeadMailer.email_will(self).deliver
	end
  	
end