class CompanySub < ActiveRecord::Base
	attr_accessible :company_id, :subcontractor_id
	belongs_to :company
	belongs_to :subcontractor, :class_name => "Company"

	acts_as_api

    api_accessible :report do |t|
        t.add :id
        #t.add :subcontractor
    end
end
