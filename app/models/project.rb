class Project < ActiveRecord::Base
	attr_accessible :name, :company_id, :active, :users, :addresses, :checklist
  	
  	has_many :project_users
  	has_many :users, :through => :project_users 
  	
  	belongs_to :company
  	has_many :addresses
  	has_many :punchlists
  	has_one :checklist

  	acts_as_api

  	api_accessible :user do |t|

  	end

  	api_accessible :project do |t|
  		t.add :name
  		t.add :addresses
  		t.add :company
  		t.add :checklist
  		t.add :punchlists
  	end
end
