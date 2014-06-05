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

	def has_subcontractor?
		subcontractor.present?
	end

## slated for deletion ##
	def users_count
		subcontractor.users.count if subcontractor
	end
## ##

    api_accessible :report do |t|
        t.add :id
        t.add :name, :if => :has_subcontractor?
        t.add :users, :if => :has_subcontractor?
        t.add :users_count, :if => :has_subcontractor?
    end
end
