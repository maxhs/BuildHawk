class Folder < ActiveRecord::Base
	attr_accessible :name, :project_id
  	belongs_to :project

  	has_many :photos, :dependent => :destroy

  	acts_as_api

  	api_accessible :projects do |t|
		t.add :id
		t.add :name
	end

	api_accessible :dashboard, :extend => :projects do |t|
		
	end

	api_accessible :details, :extend => :projects do |t|
		
	end

	api_accessible :worklist, :extend => :projects do |t|
		
	end

end