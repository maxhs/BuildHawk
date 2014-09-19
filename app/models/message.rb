class Message < ActiveRecord::Base
	attr_accessible :author_id, :company_id, :body, :user_ids, :project_ids

	belongs_to :author, :class_name => "User"
	belongs_to :company
	has_many :message_projects, :dependent => :destroy, autosave: true
    has_many :projects, :through => :message_projects , autosave: true
    has_many :message_users, :dependent => :destroy, autosave: true
    has_many :users, :through => :message_users , autosave: true
	has_many :comments

	after_commit :notify, on: :create

	def notify
		users.each do |u|
			u.notifications.create(
				:body 				=> body,
				:message_id 		=> id,
				:company_id			=> company_id,
				:notification_type 	=> self.class.name
			)
		end
	end

	acts_as_api

	api_accessible :notifications do |t|
        t.add :id
        t.add :body
        t.add :company
        t.add :target_project
        t.add :comments
    end

    api_accessible :projects, :extend => :notifications do |t|

    end

    api_accessible :details, :extend => :notifications do |t|
    	
    end
end
