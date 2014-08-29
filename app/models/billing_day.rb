class BillingDay < ActiveRecord::Base
	attr_accessible :project_user_id

	belongs_to :project_user
end
