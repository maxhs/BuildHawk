class Category < ActiveRecord::Base
	attr_accessible :name, :checklist_id, :index, :milestone, :completed_date, :subcategories_attributes
  	belongs_to :checklist
  	has_many :subcategories
  	accepts_nested_attributes_for :subcategories

  	acts_as_api

  	api_accessible :project do |t|
  		t.add :name
  		t.add :index
  		t.add :milestone
  		t.add :completed_date
  	end
end
