class ReportSub < ActiveRecord::Base
	attr_accessible :report_id, :sub_id, :count
	belongs_to :report
	belongs_to :sub

	acts_as_api

  	api_accessible :report do |t|
  		t.add :id
  		t.add :sub
  		t.add :count
  	end
end
