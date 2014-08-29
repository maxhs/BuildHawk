module BillingDay
	@queue = :billingday

	def self.perform(project_user_id)
		project_user = ProjectUser.where(:id => project_user_id).first
		if project_user
			project_user.billing_days.create
			puts "creatign a billing day for #{project_user.user.full_name} on project: #{project_user.project.name}"
		end
	end
end