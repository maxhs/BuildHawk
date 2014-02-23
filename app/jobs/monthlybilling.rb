module MonthlyBilling
	@queue = :monthly_billing
  	def self.perform
  		puts "handling monthly billing"
  		first = Date.today.beginning_of_month
  		last = Date.today.end_of_month
  		Company.all.each do |c|
  			recent_charge = c.charges.last
  			if recent_charge
	  			if recent_charge.created_at > first && recent_charge.created_at < last
	  				puts "already had a charge for this month"
	  			else 
	  				c.charges.create :description => "Monthly project billing"
	  			end
	  		else
	  			c.charges.create :description => "Monthly project billing"
	  		end
	  		puts "amount: #{c.charges.last.amount}"
  		end

  	end
end
