class CompanySub < ActiveRecord::Base
	attr_accessible :company_id
	belongs_to :company
end
