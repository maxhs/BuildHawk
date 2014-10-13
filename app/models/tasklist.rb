class Tasklist < ActiveRecord::Base
	attr_accessible :name, :project_id, :active
  	
  	has_many :tasks, :dependent => :destroy
  	belongs_to :project

    def personnel
        tasks.map(&:assignee).flatten.uniq.compact
    end

    def worklist_items
        tasks
    end
    
	acts_as_api

    api_accessible :tasklist do |t|
        t.add :id
        t.add :project
        t.add :tasks
        ### slated for deletion. fucking click labs still needs it ###
        t.add :personnel
        t.add :worklist_items
        ###
    end

  	api_accessible :user, :extend => :tasklist do |t|

  	end

  	api_accessible :projects, :extend => :tasklist do |t|
    
  	end
end