module DailyBilling
	@queue = :daily_billing

	def self.perform
		#creates a billing day for each project user
		yesterday = DateTime.now - 1.day
		ProjectUser.all.each do |p|
			last_billing = p.billing_days.last
			if !last_billing || last_billing.created_at < yesterday
				p.billing_days.create :company_id => p.user.company_id
			end
		end
	end
end