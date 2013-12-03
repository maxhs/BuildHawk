class Company < ActiveRecord::Base
	attr_accessible :name, :phone_number, :email
	has_many :users
	has_many :subcontractors, :class_name => "User"
end
