class ProjectGroup < ActiveRecord::Base
	attr_accessible :company_id, :name

	belongs_to :company
	has_many :projects

end