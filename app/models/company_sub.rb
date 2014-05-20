class CompanySub < ActiveRecord::Base
	attr_accessible :company_id, :sub_id
	belongs_to :company
	belongs_to :sub
end
