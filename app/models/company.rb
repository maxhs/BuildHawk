class Company < ActiveRecord::Base
	attr_accessible :name, :phone_number, :email, :photo_attributes, :pre_register, :contact_name
	has_many :users, :dependent => :destroy
	has_many :subcontractors, :class_name => "User", :dependent => :destroy
	has_many :projects, :dependent => :destroy
	has_many :photos, :dependent => :destroy
	has_many :checklists, :dependent => :destroy

	accepts_nested_attributes_for :photos
	acts_as_api

  	api_accessible :user do |t|
  		t.add :id
  		t.add :name
  		t.add :users
  	end
end
