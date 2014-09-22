class ReportCompany < ActiveRecord::Base
	attr_accessible :report_id, :company_id, :count
	belongs_to :report#, autosave: true
	belongs_to :company#, autosave: true
	
	acts_as_api

  	api_accessible :reports do |t|
  		t.add :id
  		t.add :company
  		t.add :count
  	end

  	api_accessible :v3_reports, :extend => :reports do |t|

    end
end
