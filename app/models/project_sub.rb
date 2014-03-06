class ProjectSub < ActiveRecord::Base
	attr_accessible :project_id, :sub_id
	belongs_to :project
	belongs_to :sub
end