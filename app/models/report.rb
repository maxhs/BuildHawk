class Report < ActiveRecord::Base
	attr_accessible :title, :report_type, :body, :user_id, :project_id, :report_fields
  	belongs_to :user
  	belongs_to :project
  	has_many :comments, :dependent => :destroy
  	has_many :report_fields, :dependent => :destroy
    has_many :report_personnel, :dependent => :destroy
    has_many :users, :through => :report_personnel, :dependent => :destroy
    has_many :photos, :dependent => :destroy

    def possible_types
      ["Daily","Safety"]
    end

  	acts_as_api

  	api_accessible :project do |t|
  		t.add :title
  		t.add :report_type
  		t.add :body
  		t.add :completed_date
  		t.add :report_fields
  	end
end
