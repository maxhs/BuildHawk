class ProjectUser < ActiveRecord::Base
	attr_accessible :project_id, :user_id, :archived, :project_group_id, :core
	belongs_to :project
	belongs_to :user
	validates_uniqueness_of :project_id, :scope => :user_id
end
