class CompanySub < ActiveRecord::Base
	attr_accessible :company_id, :subcontractor_id
	belongs_to :company
	belongs_to :subcontractor, :class_name => "Company"

	acts_as_api

	def name
		subcontractor.name if subcontractor
	end

	def users
		subcontractor.users if subcontractor
	end

    api_accessible :report do |t|
        t.add :id
        t.add :name
        t.add :users
    end
end
