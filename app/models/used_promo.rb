class UsedPromo < ActiveRecord::Base
	attr_accessible :user_id, :promo_id, :company_id

	belongs_to :company
	belongs_to :user
	belongs_to :promo
end
