class Punchlist < ActiveRecord::Base
	attr_accessible :name, :project_id, :active, :worklist
  	
  	has_many :punchlist_items, :dependent => :destroy
  	belongs_to :project

	acts_as_api

  	api_accessible :user do |t|

  	end

  	api_accessible :project do |t|

  	end
end
