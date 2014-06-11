class WorklistItem < ActiveRecord::Base
    include ActionView::Helpers::TextHelper
	attr_accessible :body, :assignee_id, :assignee, :location, :order_index, :photos, :worklist_id, :worklist, :photos_attributes, 
                  :completed, :completed_at, :assignee_attributes, :completed_by_user_id, :photos_count, :comments_count, :mobile, :user_id,
                  :sub_assignee_id

    belongs_to :worklist
    belongs_to :user
    belongs_to :completed_by_user, :class_name => "User"
	belongs_to :assignee, :class_name => "User"
    belongs_to :sub_assignee, :class_name => "Sub"
    has_many :comments, :dependent => :destroy
    has_many :photos, :dependent => :destroy
    has_many :notifications, :dependent => :destroy
    accepts_nested_attributes_for :photos, :allow_destroy => true, :reject_if => lambda { |c| c[:image].blank? }
    accepts_nested_attributes_for :assignee, :allow_destroy => true, :reject_if => lambda { |c| c[:id].blank? }

    after_commit :notify, :if => :persisted?

    default_scope { order('created_at DESC') }

    #websolr
    searchable do
        text    :body
        text    :location
        text    :assignee do
            assignee.full_name if assignee
        end
        integer :project_id do
            worklist.project.id if worklist
        end
        time    :created_at
    end

    def notify
        puts "worklist item changed"
        truncated = truncate(body, length:20)
        if completed
            # user = User.where(:id => completed_by_user_id).first if completed_by_user_id != nil
            # if user
            #     message = "#{worklist.project.name} - \"#{truncated}\" was just completed by #{user.full_name}"
            # else
                message = "#{worklist.project.name} (Worklist) - \"#{truncated}\" was just completed"
            #end
            Notification.where(:message => message,:user_id => user_id, :worklist_item_id => id, :notification_type => "Worklist").first_or_create
        else
            message = "#{worklist.project.name} (Worklist) - \"#{truncated}\" has been modified"
            user.notifications.where(:message => message,:worklist_item_id => id,:notification_type => "Worklist").first_or_create
        end

        if assignee
            message = "\"#{truncated}\" has been assigned to you for #{worklist.project.name}"
            assignee.notifications.where(:message => message,:worklist_item_id => id,:notification_type => "Worklist").first_or_create
        end
    end

    def created_date
        created_at.to_i
    end

    def project 
        worklist.project
    end

    ##for deletion
    def epoch_time
        created_date
    end
    ###

    acts_as_api

    api_accessible :worklist do |t|
  		t.add :id
        t.add :user
  		t.add :body
  		t.add :assignee
  		t.add :location
  		t.add :completed_at
  		t.add :completed
        t.add :created_date
        t.add :epoch_time
        t.add :photos
        t.add :created_at
        t.add :comments
        t.add :project
  	end

    api_accessible :dashboard, :extend => :worklist do |t|

    end

    api_accessible :projects, :extend => :worklist do |t|

    end
end
