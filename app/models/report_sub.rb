class ReportSub < ActiveRecord::Base
	attr_accessible :report_id, :sub_id
	belongs_to :report
	belongs_to :sub
end
