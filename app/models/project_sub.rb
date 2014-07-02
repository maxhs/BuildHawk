class ProjectSub < ActiveRecord::Base
	attr_accessible :project_id, :company_id
	belongs_to :project
	belongs_to :company
	validates_uniqueness_of :project_id, :scope => :company_id

	acts_as_api

  	api_accessible :projects do |t|
        t.add :id
        t.add :company
    end
    
    api_accessible :worklist, :extend => :projects do |t|

    end 

    api_accessible :details, :extend => :projects do |t|

    end 
end