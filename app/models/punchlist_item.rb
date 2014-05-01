class PunchlistItem < ActiveRecord::Base
    include ActionView::Helpers::TextHelper
	attr_accessible :body, :assignee_id, :assignee, :location, :order_index, :photos, :punchlist_id, :punchlist,
					:photos_attributes, :completed, :completed_at, :assignee_attributes, :completed_by_user_id,
                    :sub_assignee_id, :sub_assignee, :photos_count, :comments_count, :mobile, :user_id

    belongs_to :punchlist
    belongs_to :user
    belongs_to :completed_by_user, :class_name => "User"
	  belongs_to :assignee, :class_name => "User"
    belongs_to :sub_assignee, :class_name => "Sub"
    has_many :comments, :dependent => :destroy
    has_many :photos, :dependent => :destroy
    accepts_nested_attributes_for :photos, :allow_destroy => true, :reject_if => lambda { |c| c[:image].blank? }
    accepts_nested_attributes_for :assignee, :allow_destroy => true, :reject_if => lambda { |c| c[:id].blank? }

    after_commit :notify, :if => :persisted?

    default_scope { order('created_at') }

    #websolr
    searchable do
      text    :body
      text    :location
      text    :assignee do
        assignee.full_name if assignee
      end
      text    :sub_assignee do
        sub_assignee.name if sub_assignee
      end
      integer :project_id do
        punchlist.project.id if punchlist
      end
      time    :created_at
    end

    def notify
        puts "punchlist item changed"
        truncated = truncate(body, length:20)
        if completed && completed == true && user_id
            # user = User.where(:id => completed_by_user_id).first if completed_by_user_id != nil
            # if user
            #     message = "#{punchlist.project.name} - \"#{truncated}\" was just completed by #{user.full_name}"
            # else
                message = "#{punchlist.project.name} (Worklist) - \"#{truncated}\" was just completed"
            #end
            Notification.where(:message => message,:user_id => self.user_id, :punchlist_item_id => self.id, :notification_type => "Worklist").first_or_create
        elsif user_id
            message = "#{punchlist.project.name} (Worklist) - \"#{truncated}\" has been modified"
            Notification.where(:message => message,:user_id => user_id, :punchlist_item_id => id,:notification_type => "Worklist").first_or_create
        end

        if assignee
            message = "\"#{truncated}\" has been assigned to you for #{punchlist.project.name}"
            Notification.where(:message => message,:user_id => assignee.id, :punchlist_item_id => id,:notification_type => "Worklist").first_or_create
        end
    end

    acts_as_api

    api_accessible :projects do |t|
  		t.add :id
  		t.add :body
  		t.add :assignee
        t.add :sub_assignee
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
