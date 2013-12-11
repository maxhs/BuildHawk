class ReportField < ActiveRecord::Base
	  attr_accessible :title, :type, :body, :user_id, :report_id
  	belongs_to :user
  	belongs_to :report

  	acts_as_api

  	api_accessible :projects do |t|
  		t.add :title
  		t.add :type
  		t.add :body
  		t.add :user
  		t.add :report_id
  	end
end
