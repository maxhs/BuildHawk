class Promo < ActiveRecord::Base
	attr_accessible :name, :percentage, :amount, :days, :users, :project_id, :company_id, :user_id

	belongs_to :user
	belongs_to :company
	belongs_to :project
end
