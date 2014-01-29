class Folder < ActiveRecord::Base
	attr_accessible :name, :project_id, :project
  	belongs_to :project

  	has_many :photos

  	acts_as_api

end