class Folder < ActiveRecord::Base
	attr_accessible :name, :project_id
  	belongs_to :project

  	has_many :photos, :dependent => :destroy

  	acts_as_api

end