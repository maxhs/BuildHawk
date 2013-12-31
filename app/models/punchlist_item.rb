class PunchlistItem < ActiveRecord::Base
    include ActionView::Helpers::TextHelper
	attr_accessible :body, :assignee_id, :assignee, :location, :order_index, :photos, :punchlist_id, :punchlist,
					:photos_attributes, :completed, :completed_at, :assignee_attributes, :completed_by_user_id,
                    :assignee_name, :photos_count, :comments_count

    belongs_to :punchlist
    belongs_to :completed_by_user, :class_name => "User"
	belongs_to :assignee, :class_name => "User"
    has_many :subs
    has_many :comments, :dependent => :destroy
    has_many :photos, :dependent => :destroy
    accepts_nested_attributes_for :photos, :allow_destroy => true, :reject_if => lambda { |c| c[:image].blank? }
    accepts_nested_attributes_for :assignee, :allow_destroy => true, :reject_if => lambda { |c| c[:id].blank? }

    after_save :clean_name
    after_commit :notify, :if => :persisted?

    default_scope { order('created_at') }

    def clean_name 
        if assignee && assignee.full_name
            assignee_name = assignee.full_name
        end
    end

    def notify
        truncated = truncate(body, length:20)
        message = "\"#{truncated}\" has been assigned to you for #{punchlist.project.name}"
        Notification.where(:message => message,:user_id => self.assignee.id, :punchlist_item_id => self.id,:notification_type => "Worklist",:user => self.assignee).first_or_create
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
