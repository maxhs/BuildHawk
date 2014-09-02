module DailyBilling
	@queue = :daily_billing

	def self.perform
		Project.where(active: true).each do |p|
			p.project_users.each do |pu|
				pu.billing_days.create
				puts "creatign a billing day for #{pu.user.full_name} on project: #{pu.project.name}"
			end
		end
	end
end