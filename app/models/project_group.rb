class ProjectGroup < ActiveRecord::Base
	attr_accessible :company_id, :name, :projects_count

	belongs_to :company
	has_many :projects

	def group_projects
		projects.sort_by{|p| p.name.downcase}.as_json(:include => [:address, :users, :subs])
	end
	
	acts_as_api

  	api_accessible :projects do |t|
        t.add :id
        t.add :name
        #deprecated in 1.06
  		t.add :projects_count
  	end

  	api_accessible :dashboard, :extend => :projects do |t|
  		
  	end

  	api_accessible :details, :extend => :projects do |t|
  		t.add :projects
  	end
end