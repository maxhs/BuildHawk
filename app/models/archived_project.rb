class ArchivedProject < ActiveRecord::Base
	attr_accessible :project_id, :user_id
	belongs_to :project
	belongs_to :user
	validates_uniqueness_of :project_id, :scope => :user_id
end
