class ProjectGroup < ActiveRecord::Base
	attr_accessible :company_id, :name

	belongs_to :company
	has_many :projects

	acts_as_api

  	api_accessible :projects do |t|
  		t.add :name
  		t.add :id
  	end
end