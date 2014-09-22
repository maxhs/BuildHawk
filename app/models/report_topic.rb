class ReportTopic < ActiveRecord::Base
	attr_accessible :report_id, :safety_topic_id
	belongs_to :report#, autosave: true
	belongs_to :safety_topic#, autosave: true

	acts_as_api

  	api_accessible :reports do |t|
  		t.add :id
  		t.add :report_id
  		t.add :safety_topic
  	end

  	api_accessible :v3_reports, :extend => :reports do |t|

    end
end
