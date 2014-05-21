class CompanySub < ActiveRecord::Base
	attr_accessible :company_id, :subcontractor_id
	belongs_to :company
	belongs_to :subcontractor, :class_name => "Company"
end
