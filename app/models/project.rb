class Project < ActiveRecord::Base
	attr_accessible :name, :company_id, :active, :users, :address_attributes, :projects_users_attributes, :checklist, :photos
  	
  	has_many :project_users
  	has_many :users, :through => :project_users 
  	
  	belongs_to :company
  	has_one :address
  	has_many :punchlists
    has_many :photos
    has_many :reports
  	has_one :checklist

    accepts_nested_attributes_for :address
    accepts_nested_attributes_for :project_users
    
    after_create :assign_core

    def assign_core
      core = CoreChecklist.last
      new_checklist = Checklist.create
      new_checklist.categories << core.categories
      self.update_attribute :checklist, new_checklist 
    end
  	
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
