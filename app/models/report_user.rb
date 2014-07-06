class ReportUser < ActiveRecord::Base
	attr_accessible :report_id, :user_id, :hours
	belongs_to :report
	belongs_to :user

	def sub
		return false
	end
	
	acts_as_api

  	api_accessible :reports do |t|
  		t.add :id
  		t.add :user
  		t.add :hours
  	end
end
