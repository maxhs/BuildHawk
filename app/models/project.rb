class Project < ActiveRecord::Base
	attr_accessible :name, :user_id, :company_id, :active
  	
  	has_many :project_users
  	has_many :users, :through => :project_users 
  	
  	belongs_to :company
  	has_many :addresses
  	has_many :punchlists
  	has_one :checklist
end
