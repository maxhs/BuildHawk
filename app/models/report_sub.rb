class ReportSub < ActiveRecord::Base
	attr_accessible :report_id, :sub_id, :count
	belongs_to :report, autosave: true
	belongs_to :sub, autosave: true

	def user
		return false
	end
	
	acts_as_api

  	api_accessible :reports do |t|
  		t.add :id
  		t.add :sub
  		t.add :count
  	end
end
