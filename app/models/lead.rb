class Lead < ActiveRecord::Base
	attr_accessible :name, :company_name, :full_name, :email, :phone

	after_create :email_will
	after_create :clean_phone

	def email_will
		LeadMailer.email_will(self).deliver
	end

	def clean_phone
		if phone && phone.length
	        phone = phone.gsub(/[^0-9a-z ]/i, '').gsub(/\s+/,'')
	        self.save
	    end
	end
  	
end