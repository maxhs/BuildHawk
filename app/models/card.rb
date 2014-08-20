class Card < ActiveRecord::Base
	require 'stripe'

	attr_accessible :company_id, :customer_token, :public_digits, :expiration, :active

	belongs_to :company
end
