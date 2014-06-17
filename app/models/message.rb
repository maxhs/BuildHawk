class Message < ActiveRecord::Base
	attr_accessible :user_id, :company_id, :target_project_id, :body

	belongs_to :user
	belongs_to :company
	belongs_to :target_project, :class_name => "Project"
	has_many :users
	has_many :comments

	acts_as_api

	api_accessible :report do |t|
        t.add :id
        t.add :body
        t.add :company
        t.add :target_project
        t.add :comments
    end
end
