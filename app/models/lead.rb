class Lead < ActiveRecord::Base
	attr_accessible :name, :full_name, :email, :phone_number

	after_create :email_will

	def email_will
		puts "should be emailing will"
		LeadMailer.email_will(self).deliver
	end
  	
end