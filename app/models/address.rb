class Address < ActiveRecord::Base
    attr_accessible :street1, :street2, :city, :zip, :country, :phone_number
  	belongs_to :user
  	belongs_to :company
  	belongs_to :project
end
