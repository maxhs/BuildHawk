class Card < ActiveRecord::Base
	require 'stripe'

	attr_accessible :company_id, :customer_token, :public_digits, :expiration

	belongs_to :company
end
