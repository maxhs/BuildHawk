class PunchlistItem < ActiveRecord::Base
	attr_accessible :body, :assignee_id, :assignee, :project_id, :project, :location, 
					:photos_attributes, :completed, :completed_at

	belongs_to :project
	belongs_to :assignee, :class_name => "User"

	has_many :photos
    accepts_nested_attributes_for :photos

    acts_as_api

    api_accessible :projects do |t|
  		t.add :id
  		t.add :body
  		t.add :assignee
  		t.add :location
  		t.add :completed_at
  		t.add :completed
  	end
end
