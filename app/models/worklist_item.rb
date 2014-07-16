class WorklistItem < ActiveRecord::Base

	attr_accessible :body, :assignee_id, :assignee, :location, :order_index, :photos, :worklist_id, :worklist, :photos_attributes, 
                    :completed, :completed_at, :assignee_attributes, :completed_by_user_id, :photos_count, :comments_count, :mobile, :user_id,
                    :sub_assignee_id, :assigned_name, :assigned_phone, :assigned_email, :connect_assignee_id

    belongs_to :worklist
    belongs_to :user
    belongs_to :completed_by_user, :class_name => "User"
	belongs_to :assignee, :class_name => "User"
    belongs_to :sub_assignee, :class_name => "Sub"
    belongs_to :connect_assignee, :class_name => "ConnectUser"
    has_many :comments, :dependent => :destroy
    has_many :photos, :dependent => :destroy
    has_many :notifications, :dependent => :destroy
    has_many :activities, :dependent => :destroy
    
    accepts_nested_attributes_for :photos, :allow_destroy => true, :reject_if => lambda { |c| c[:image].blank? }
    accepts_nested_attributes_for :assignee, :allow_destroy => true, :reject_if => lambda { |c| c[:id].blank? }

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

    def notify(current_user)
        if body.length > 20
            truncated = "#{body[0..20]}..."
        else
            truncated = body
        end
        
        if completed
            
            text = "#{worklist.project.name} (Worklist) - \"#{truncated}\" was completed by #{current_user.full_name}"
            Notification.where(:body => text,:user_id => user_id, :worklist_item_id => id, :notification_type => "Worklist").first_or_create
            activities.create(
                :user_id => current_user.id,
                :project_id => worklist.project.id,
                :worklist_item_id => id,
                :body => "This item was completed by #{current_user.full_name}.",
                :activity_type => self.class.name
            )
        else
            body = "#{worklist.project.name} (Worklist) - \"#{truncated}\" has been modified"
            user.notifications.where(:body => body,:worklist_item_id => id,:notification_type => "Worklist").first_or_create
            activities.create(
                :user_id => current_user.id,
                :project_id => worklist.project.id,
                :worklist_item_id => id,
                :body => "This item was modified by #{current_user.full_name}.",
                :activity_type => self.class.name
            )
        end

        if assignee
            body = "\"#{truncated}\" has been assigned to you for #{worklist.project.name}"
            assignee.notifications.where(:body => body,:worklist_item_id => id,:notification_type => "Worklist").first_or_create
            activities.create(
                :user_id => current_user.id,
                :project_id => worklist.project.id,
                :worklist_item_id => id,
                :body => "This item was assigned to #{assignee.full_name}.",
                :activity_type => self.class.name
            )
        end
    end

    def created_date
        created_at.to_i
    end

    def project_id
        worklist.project.id
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
        t.add :worklist_id
        t.add :user
  		t.add :body
  		t.add :assignee
  		t.add :location
  		t.add :completed_at
        t.add :created_at
  		t.add :completed
        t.add :created_date
        t.add :project_id
        ## for deletion
        t.add :epoch_time
  	end

    api_accessible :connect do |t|
        t.add :id
        t.add :worklist_id
        t.add :body
        t.add :assignee
        t.add :location
        t.add :completed_at
        t.add :created_at
        t.add :completed
        t.add :created_date
        t.add :project
    end

    api_accessible :dashboard, :extend => :worklist do |t|

    end

    api_accessible :projects, :extend => :worklist do |t|

    end

    api_accessible :notifications, :extend => :worklist do |t|

    end

    api_accessible :details, :extend => :worklist do |t|
        t.add :activities
        t.add :photos
        t.add :comments
    end

    api_accessible :reminders do |t|
        t.add :id
        t.add :worklist_id
        t.add :user
        t.add :body
        t.add :assignee
        t.add :location
        t.add :completed_at
        t.add :created_at
        t.add :completed
        t.add :created_date
    end
end
