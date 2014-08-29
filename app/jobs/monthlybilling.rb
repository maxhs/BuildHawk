module MonthlyBilling
	@queue = :monthly_billing
  	def self.perform
  		puts "handling monthly billing"
  		first = Date.today.beginning_of_month
  		last = Date.today.end_of_month
  		Company.all.each do |c|
  			recent_charge = c.charges.last
  			c.projects.where(active: true).each do |p|
  				puts "Calculating billing for #{p.name}"
  				p.project_users.each do |pu|
  					active_days = pu.billing_days.where('created_at > ? and created_at < ?',first,last).count
  				end
  			end
  		end
  	end
end
