class ProjectUser < ActiveRecord::Base
	attr_accessible :project_id, :user_id, :connect_user_id, :archived, :project_group_id, :core
	belongs_to :project
	belongs_to :user
	belongs_to :connect_user
	validates_uniqueness_of :project_id, :scope => :user_id
	validates_uniqueness_of :connect_user_id, :scope => :project_id

	after_create :notify

	def notify
		user = User.where(:id => user_id).first
		if user
	        user.notifications.where(
	        	:body => "You were added to a project: #{project.name}", 
	        	:project_id => project_id,
	        	:notification_type => "Project"
	        ).first_or_create
	    end
	end
end
