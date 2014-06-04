class ReportTopic < ActiveRecord::Base
	attr_accessible :report_id, :safety_topic_id
	belongs_to :report, autosave: true
	belongs_to :safety_topic, autosave: true
end
