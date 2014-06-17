class Message < ActiveRecord::Base
	attr_accessible :user_id, :company_id, :target_project_id, :body, :recipient_ids

	belongs_to :user
	belongs_to :company
	belongs_to :target_project, :class_name => "Project"
	has_many :recipients, :foreign_key => 'message_id', :class_name => "User"
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
