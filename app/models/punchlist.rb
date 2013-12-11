class Punchlist < ActiveRecord::Base
	attr_accessible :name, :project_id, :active, :worklist
  	
  	has_many :punchlist_items, :dependent => :destroy
  	belongs_to :project

	acts_as_api

  	api_accessible :user do |t|
  		t.add :punchlist_items
  	end

  	api_accessible :projects do |t|
  		t.add :punchlist_items
  	end
end
