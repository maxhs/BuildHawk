class ProjectGroup < ActiveRecord::Base
	attr_accessible :company_id, :name, :projects_count

	belongs_to :company
	has_many :projects

	def group_projects
		projects.as_json(:include => [:address, :users, :subs])
	end
	
	acts_as_api

  	api_accessible :projects do |t|
  		t.add :name
  		t.add :id
  		t.add :projects_count
  		t.add :group_projects
  	end
end