class Company < ActiveRecord::Base
	attr_accessible :name, :phone_number, :email
	has_many :users
	has_many :subcontractors, :class_name => "User"

	acts_as_api

  	api_accessible :user do |t|
  		t.add :id
  		t.add :name
  		t.add :users
  	end
end
