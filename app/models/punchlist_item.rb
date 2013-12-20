class PunchlistItem < ActiveRecord::Base
	attr_accessible :body, :assignee_id, :assignee, :project_id, :project, :location, :order_index, :photos,
					:photos_attributes, :completed, :completed_at, :assignee_attributes, :completed_by_user_id,
                    :assignee_name

	belongs_to :project
    belongs_to :punchlist
    belongs_to :completed_by_user, :class_name => "User"
	belongs_to :assignee, :class_name => "User"
    has_many :comments, :dependent => :destroy
    has_many :photos, :dependent => :destroy
    accepts_nested_attributes_for :photos, :allow_destroy => true, :reject_if => lambda { |c| c[:image].blank? }
    accepts_nested_attributes_for :assignee, :allow_destroy => true, :reject_if => lambda { |c| c[:id].blank? }

    after_save :clean_name

    default_scope { order('created_at') }

    def clean_name
        if assignee && assignee.full_name
            assignee_name = assignee.full_name
        end
    end


    acts_as_api

    api_accessible :projects do |t|
  		t.add :id
  		t.add :body
  		t.add :assignee
        t.add :assignee_name
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
