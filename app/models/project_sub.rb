class ProjectSub < ActiveRecord::Base
	attr_accessible :project_id, :company_sub_id
	belongs_to :project
	belongs_to :company_sub
	validates_uniqueness_of :project_id, :scope => :company_sub_id

	acts_as_api

  	api_accessible :projects do |t|
        t.add :id
        t.add :company_sub
    end
end