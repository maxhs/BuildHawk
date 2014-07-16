class ReportUser < ActiveRecord::Base
	attr_accessible :report_id, :user_id, :connect_user_id, :hours
	belongs_to :report
	belongs_to :user
	belongs_to :connect_user

	after_create :assign

	def assign
		if connect_user
			puts "creating a project user for new report user"
			#report.project.project_users.where(:connect_user_id => connect_user_id).first_or_create
		end
	end

	def sub
		return false
	end
	
	acts_as_api

  	api_accessible :reports do |t|
  		t.add :id
  		t.add :user
  		t.add :connect_user
  		t.add :hours
  	end
end
