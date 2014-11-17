class Promo < ActiveRecord::Base
	attr_accessible :name, :percentage, :amount, :company_id, :user_id

	belongs_to :user
	belongs_to :company
end
