class Worklist < ActiveRecord::Base
	attr_accessible :name, :project_id, :active, :worklist
  	
  	has_many :worklist_items, :dependent => :destroy
  	belongs_to :project

    def personnel
        (worklist_items.map(&:sub_assignee).flatten + worklist_items.map(&:assignee).flatten).uniq.compact
    end

	acts_as_api

    api_accessible :worklist do |t|
        t.add :id
        t.add :project
        t.add :worklist_items
        ###slated for deletion###
        t.add :personnel
        ###
    end

  	api_accessible :user, :extend => :worklist do |t|

  	end

  	api_accessible :projects, :extend => :worklist do |t|
    
  	end

    api_accessible :notifications, :extend => :worklist do |t|
    
    end 
end