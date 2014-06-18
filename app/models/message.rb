class Message < ActiveRecord::Base
	attr_accessible :author_id, :company_id, :target_project_id, :body, :recipient_ids

	belongs_to :author
	belongs_to :company
	belongs_to :target_project, :class_name => "Project"
	has_many :message_users, :dependent => :destroy, autosave: true
    has_many :users, :through => :message_users , autosave: true
	has_many :comments

	after_commit :notify, on: :create

	def notify
		users.each do |u|
			u.notifications.create(
				:alert 				=> body,
				:message_id 		=> id,
				:project_id 		=> target_project_id,
				:notification_type 	=> "Message"
			)
		end
	end

	acts_as_api

	api_accessible :report do |t|
        t.add :id
        t.add :body
        t.add :company
        t.add :target_project
        t.add :comments
    end
end
