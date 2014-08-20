class Card < ActiveRecord::Base
	require 'stripe'

	attr_accessible :company_id, :card_id, :last4, :exp_month, :exp_year, :active, :brand,
					:address_line1, :address_line2, :address_city, :address_state, :address_zip,
            		:country, :name

	belongs_to :company
end
