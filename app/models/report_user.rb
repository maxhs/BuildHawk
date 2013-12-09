class ReportUser < ActiveRecord::Base
	attr_accessible :report_id, :report, :user, :user_id, :full_name
	belongs_to :report
	belongs_to :user	
end
