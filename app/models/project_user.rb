class ProjectUser < ActiveRecord::Base
	attr_accessible :project_id, :user_id, :hidden, :project_group_id, :core, :company_id
	belongs_to :project
	belongs_to :user
	belongs_to :company
	has_many :billing_days
	validates :user, presence: true
	validates_uniqueness_of :project_id, :scope => :user_id

	after_create :notify

	def notify
		user = User.where(id: user_id).first
        user.notifications.create(
        	body: "You were added to a project: #{project.name}", 
        	project_id: project_id,
        	notification_type: "Project"
        ) if user
	end

	def hide_project
		self.update_columns hidden: true, project_group_id: nil
		project.update_column :project_group_id, nil
	end

	acts_as_api

  	api_accessible :details do |t|
  		t.add :id
  		t.add :user
  		t.add :project_id
  	end
end
