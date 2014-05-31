class ProjectUser < ActiveRecord::Base
	attr_accessible :project_id, :user_id, :archived, :project_group_id, :core
	belongs_to :project
	belongs_to :user
	validates_uniqueness_of :project_id, :scope => :user_id

	after_create :notify

	def notify
		user = User.find user_id
        user.notifications.where(
        	:message => "You were added to a project: #{project.name}", 
        	:project_id => project_id,
        	:notification_type => "Project"
        ).first_or_create
        puts "should have just sent a new project user push notification to #{user.full_name}"
	end
end
