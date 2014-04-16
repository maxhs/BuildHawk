class SafetyTopic < ActiveRecord::Base
	attr_accessible :report_id, :company_id, :title, :info, :core
	belongs_to :company
	belongs_to :report

	acts_as_api

  	api_accessible :report do |t|
  		t.add :title
  		t.add :info
  		t.add :report_id
  		t.add :company_id
  	end
end
