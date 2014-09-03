class BillingDay < ActiveRecord::Base
	attr_accessible :project_user_id, :company_id

	belongs_to :project_user
	belongs_to :company
end
