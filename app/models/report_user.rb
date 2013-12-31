class ReportUser < ActiveRecord::Base
	attr_accessible :report_id, :user_id, :count
	belongs_to :report
	belongs_to :user

	acts_as_api

  	api_accessible :report do |t|
  		t.add :id
  		t.add :user
  		t.add :count
  	end
end
