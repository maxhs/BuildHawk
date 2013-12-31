class ReportUser < ActiveRecord::Base
	attr_accessible :report_id, :user_id
	belongs_to :report
	belongs_to :user

	acts_as_api

  	api_accessible :report do |t|
  		t.add :id
  		t.add :user
  	end
end
