class Task < ActiveRecord::Base

	attr_accessible :body, :user_ids, :location, :order_index, :photos, :tasklist_id, :tasklist, :photos_attributes, :completed, 
                    :completed_at, :completed_by_user_id, :photos_count, 
                    :comments_count, :mobile, :user_id, :user, :assigned_name, :assigned_phone, :assigned_email, :approved,
                    :assignee_ids

    belongs_to :tasklist
    belongs_to :user
    belongs_to :completed_by_user, :class_name => "User"
	belongs_to :assignee, :class_name => "User"
    has_many :comments, dependent: :destroy
    has_many :photos, dependent: :destroy
    has_many :notifications, dependent: :destroy
    has_many :activities, dependent: :destroy

    has_many :task_users, dependent: :destroy, autosave: true
    has_many :assignees, through: :task_users, autosave: true, source: :user
    
    accepts_nested_attributes_for :photos, allow_destroy: true, :reject_if => lambda { |c| c[:image].blank? }
    #accepts_nested_attributes_for :assignee, :allow_destroy => true, :reject_if => lambda { |c| c[:id].blank? }

    after_create :notify

    default_scope { order('created_at DESC') }

    #websolr
    searchable do
        text    :body
        text    :location
        text    :assignee do
            assignee.full_name if assignee
        end
        integer :project_id do
            tasklist.project.id if tasklist
        end
        time    :created_at
    end

    def notify
        if assignees && assignees.count > 0
            assignees.each do |assignee|
                if assignee.email_permissions && assignee.email && assignee.email.length > 0
                    assignee.email_task(self)
                elsif assignee.text_permissions && assignee.phone && assignee.phone.length > 0
                    assignee.text_task(self)
                end
            end
        end
    end

    def export
        if assignees && assignees.count > 0
            assignees.each do |assignee|
                assignee.email_task(self) if assignee.email_permissions && assignee.email && assignee.email.length > 0    
            end
        end
    end

    def log_activity(current_user)
        if body.length > 20
            truncated = "#{body[0..20]}..."
        else
            truncated = body
        end
        
        if completed
            
            text = "#{tasklist.project.name} (Tasklist) - \"#{truncated}\" was completed by #{current_user.full_name}"
            Notification.where(:body => text,:user_id => user_id, :task_id => id, :notification_type => "Tasklist").first_or_create
            activities.create(
                :user_id => current_user.id,
                :project_id => tasklist.project.id,
                :task_id => id,
                :body => "This item was completed by #{current_user.full_name}.",
                :activity_type => self.class.name
            )
        else
            body = "#{tasklist.project.name} (Tasklist) - \"#{truncated}\" has been modified"
            user.notifications.where(:body => body,:task_id => id,:notification_type => "Tasklist").first_or_create if user
            activities.create(
                :user_id => current_user.id,
                :project_id => tasklist.project.id,
                :task_id => id,
                :body => "This item was modified by #{current_user.full_name}.",
                :activity_type => self.class.name
            )
        end

        if assignee
            body = "\"#{truncated}\" has been assigned to you for #{tasklist.project.name}"
            assignee.notifications.where(:body => body,:task_id => id,:notification_type => "Tasklist").first_or_create
            activities.create(
                :user_id => current_user.id,
                :project_id => tasklist.project.id,
                :task_id => id,
                :body => "This item was assigned to #{assignee.full_name}.",
                :activity_type => self.class.name
            )
        end
    end

    def created_date
        created_at.to_i
    end


    def project_id
        tasklist.project.id
    end

    def project
        tasklist.project
    end

    def abbreviated_body
        if body.length > 15
           "#{body[0..15]}..."
        else
            body
        end        
    end

    def epoch_time
        created_date
    end

    def assignee
        assignees[0]
    end

    ### API compatibility
    def worklist_id
        tasklist.id
    end
    ###

    acts_as_api

    api_accessible :tasklist do |t|
  		t.add :id
        t.add :epoch_time
        t.add :tasklist_id
        t.add :user
        t.add :photos
  		t.add :body
  		t.add :assignee
        t.add :assignees
  		t.add :location
  		t.add :completed_at
        t.add :created_at
  		t.add :completed
        t.add :created_date
        t.add :project_id
        t.add :approved
        ## deprecated
        t.add :worklist_id
  	end

    api_accessible :connect do |t|
        t.add :id
        t.add :epoch_time
        t.add :worklist_id
        t.add :tasklist_id
        t.add :user
        t.add :photos
        t.add :body
        t.add :assignee
        t.add :assignees
        t.add :location
        t.add :completed_at
        t.add :created_at
        t.add :completed
        t.add :created_date
        t.add :project
        t.add :approved
    end

    api_accessible :dashboard, :extend => :tasklist do |t|

    end

    api_accessible :projects, :extend => :tasklist do |t|

    end

    api_accessible :notifications, :extend => :tasklist do |t|

    end

    api_accessible :notifications, :extend => :tasklist do |t|

    end

    api_accessible :details, :extend => :tasklist do |t|
        t.add :activities
        t.add :comments
    end

    api_accessible :reminders do |t|
        t.add :id
        t.add :worklist_id
        t.add :tasklist_id
        t.add :user
        t.add :body
        t.add :assignee
        t.add :assignees
        t.add :location
        t.add :completed_at
        t.add :created_at
        t.add :completed
        t.add :created_date
        t.add :epoch_time
    end
end
