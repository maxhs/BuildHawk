class Company < ActiveRecord::Base
	attr_accessible :name, :phone_number, :email, :photo_attributes, :pre_register, :contact_name
	has_many :users
	has_many :subcontractors, :class_name => "User"
	has_many :projects
	has_many :photos
	has_many :checklists

	accepts_nested_attributes_for :photos
	acts_as_api

  	api_accessible :user do |t|
  		t.add :id
  		t.add :name
  		t.add :users
  	end
end
