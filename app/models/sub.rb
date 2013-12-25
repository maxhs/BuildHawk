class Sub < ActiveRecord::Base
	attr_accessible :name, :company_id, :company, :email, :phone_number
  	belongs_to :company
  	has_many :users
end
