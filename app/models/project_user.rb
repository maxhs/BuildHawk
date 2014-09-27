class ProjectUser < ActiveRecord::Base
	attr_accessible :project_id, :user_id, :connect_user_id, :archived, :project_group_id, :core
	belongs_to :project
	belongs_to :user
	belongs_to :connect_user
	has_many :billing_days
	validates :user, presence: true
	validates_uniqueness_of :project_id, :scope => :user_id, if: "connect_user_id.nil?"
	validates_uniqueness_of :project_id, :scope => :connect_user_id, if: "user_id.nil?"

	after_create :notify

	def notify
		puts "just created a project connect user: #{connect_user.first_name}" if connect_user
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
  		t.add :connect_user
  		t.add :project_id
  	end
end
