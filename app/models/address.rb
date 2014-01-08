class Address < ActiveRecord::Base
    attr_accessible :street1, :street2, :city, :zip, :country, :phone_number, :state, :latitude, :longitude
  	belongs_to :user
  	belongs_to :company
  	belongs_to :project

    reverse_geocoded_by :latitude, :longitude
    geocoded_by :formatted_address
    after_validation :geocode

    def formatted_address
      "#{street1}, #{city}, #{state} #{zip}"
    end
  	
    acts_as_api

  	api_accessible :projects do |t|
  		t.add :street1
  		t.add :street2
  		t.add :city
  		t.add :zip
  		t.add :country
  		t.add :phone_number
      t.add :formatted_address
      t.add :latitude
      t.add :longitude
  	end

    api_accessible :user, :extend => :projects do |t|
      
    end

    api_accessible :company, :extend => :projects do |t|
      
    end
end
