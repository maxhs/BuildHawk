class Card < ActiveRecord::Base
	require 'stripe'

	attr_accessible :company_id, :customer_token, :last4, :exp_month, :exp_year, :active

	belongs_to :company
end
