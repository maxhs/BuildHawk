class PunchlistItem < ActiveRecord::Base
	attr_accessible :body, :assignee_id, :assignee, :project_id, :project, :location, :order_index,
					:photos_attributes, :completed, :completed_at, :assignee_attributes

	belongs_to :project
    belongs_to :punchlist
	belongs_to :assignee, :class_name => "User"
    has_many :comments, :dependent => :destroy
	has_many :photos
    accepts_nested_attributes_for :photos, :allow_destroy => true# :reject_if => lambda { |c| c[:image_file_name].blank? }
    accepts_nested_attributes_for :assignee, :allow_destroy => true

    acts_as_api

    api_accessible :projects do |t|
  		t.add :id
  		t.add :body
  		t.add :assignee
  		t.add :location
  		t.add :completed_at
  		t.add :completed
        t.add :photos
        t.add :created_at
        t.add :comments
  	end

    api_accessible :dashboard, :extend => :projects do |t|

    end

    api_accessible :punchlist, :extend => :projects do |t|

    end
end
