class Report < ActiveRecord::Base
	attr_accessible :title, :type, :body, :user_id, :project_id, :report_fields
  	belongs_to :user
  	belongs_to :project
  	has_many :comments
  	has_many :report_fields

  	acts_as_api

  	api_accessible :project do |t|
  		t.add :title
  		t.add :type
  		t.add :body
  		t.add :completed_date
  		t.add :report_fields
  	end
end
