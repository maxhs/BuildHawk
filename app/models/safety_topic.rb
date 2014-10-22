class SafetyTopic < ActiveRecord::Base
	attr_accessible :company_id, :title, :info, :core
	belongs_to :company

	acts_as_api

  	api_accessible :reports do |t|
        t.add :id
  		t.add :title
  		t.add :info
  		t.add :core
        t.add :company_id
  	end

    api_accessible :v3_reports, :extend => :reports do |t|

    end
    
end
