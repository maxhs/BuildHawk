class ProjectUser < ActiveRecord::Base
	attr_accessible :project_id, :user_id, :archived, :project_group_id, :core, :company_id
	belongs_to :project
	belongs_to :user
	belongs_to :company
	has_many :billing_days
	validates :user, presence: true
	validates_uniqueness_of :project_id, :scope => :user_id

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

	def hide_project
		self.archived = true
		self.project_group_id = nil
		self.save

		project.update_attribute :project_group_id, nil
	end

	acts_as_api

  	api_accessible :details do |t|
  		t.add :id
  		t.add :user
  		t.add :project_id
  	end
end
