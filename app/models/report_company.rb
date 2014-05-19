class ReportCompany < ActiveRecord::Base
	attr_accessible :report_id, :company_id, :count
	belongs_to :report, autosave: true
	belongs_to :company, autosave: true
	
	acts_as_api

  	api_accessible :report do |t|
  		t.add :id
  		t.add :company
  		t.add :count
  	end
end
