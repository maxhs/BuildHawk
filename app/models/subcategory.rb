class Subcategory < ActiveRecord::Base
	attr_accessible :name, :category_id, :index, :milestone, :completed_date, :checklist_items
  	belongs_to :category
  	has_many :checklist_items, :dependent => :destroy

  	acts_as_api

  	api_accessible :project do |t|
  		t.add :name
  		t.add :category_id
  		t.add :index
  		t.add :milestone
  		t.add :completed_date
  	end
end
