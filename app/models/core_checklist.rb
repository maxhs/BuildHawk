class CoreChecklist < ActiveRecord::Base
  	attr_accessible :categories
  	has_many :categories
  	accepts_nested_attributes_for :categories
end