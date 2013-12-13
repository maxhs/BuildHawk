class Report < ActiveRecord::Base
	attr_accessible :title, :report_type, :body, :user_id, :project_id, :report_fields, :weather, :photos_attributes, :users_attributes, :report_users_attributes,
                  :users, :user_ids
  	
    belongs_to :author, :class_name => "User"
  	belongs_to :project
  	has_many :comments, :dependent => :destroy
  	has_many :report_fields, :dependent => :destroy
    has_many :report_users, :dependent => :destroy
    has_many :users, :through => :report_users
    has_many :photos, :dependent => :destroy

    accepts_nested_attributes_for :users
    accepts_nested_attributes_for :photos# :reject_if => lambda { |c| c[:image_file_name].blank? }

    def possible_types
      ["Daily","Safety"]
    end

  	acts_as_api

  	api_accessible :projects do |t|
  		t.add :title
  		t.add :report_type
  		t.add :body
  		t.add :report_fields
  	end
end
