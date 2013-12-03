class Address < ActiveRecord::Base
    attr_accessible :street1, :street2, :city, :zip, :country, :phone_number
  	belongs_to :user
  	belongs_to :company
  	belongs_to :project

  	acts_as_api

  	api_accessible :project do |t|
  		t.add :street1
  		t.add :street2
  		t.add :city
  		t.add :zip
  		t.add :country
  		t.add :phone_number
  	end
end
