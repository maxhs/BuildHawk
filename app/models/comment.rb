class Comment < ActiveRecord::Base
    
	attr_accessible :body, :user_id, :report_id, :checklist_item_id, :task_id, :mobile, :message_id
  	belongs_to :user
  	belongs_to :report
  	belongs_to :checklist_item, counter_cache: true
  	belongs_to :task, counter_cache: true
    belongs_to :message
    has_one :notification, dependent: :destroy
  	has_many :photos
    has_one :activity, dependent: :destroy

    validates_presence_of :body
    validates :body, :length => { :minimum => 1 }
    default_scope { order('created_at ASC') }

    after_commit :notify, on: :create

    def project
        if report
            report.project
        elsif checklist_item
            checklist_item.checklist.project
        elsif task
            task.tasklist.project
        elsif message
            message.target_project
        end
    end

    def notify
        Activity.create(
            :user_id => user_id,
            :body => "\"#{body}\"",
            :checklist_item_id => checklist_item_id,
            :report_id => report_id,
            :task_id => task_id,
            :message_id => message_id,
            :project_id => project.id, 
            :comment_id => id,
            :activity_type => self.class.name
        )

        if report && report.author
            report.author.notifications.where(
                :body => body, 
                :report_id => report_id,
                :comment_id => id,
                :notification_type => self.class.name
            ).first_or_create
        elsif task
            task.user.notifications.where(
                :body => body, 
                :task_id => task_id,
                :comment_id => id,
                :notification_type => self.class.name
            ).first_or_create
        end
    end

    def epoch_time
        created_at.to_i
    end

  	acts_as_api

  	api_accessible :user do |t|

  	end

  	api_accessible :projects do |t|
        t.add :id
        t.add :body
        t.add :user
        t.add :created_at
        t.add :epoch_time
  	end

  	api_accessible :dashboard, :extend => :projects do |t|

  	end

    api_accessible :checklists, :extend => :projects do |t|

    end

    api_accessible :details, :extend => :projects do |t|

    end

    api_accessible :tasklist, :extend => :projects do |t|

    end

    api_accessible :reports, :extend => :projects do |t|

    end

    api_accessible :v3_reports, :extend => :reports do |t|

    end
    
    api_accessible :notifications, :extend => :projects do |t|

    end

    api_accessible :reminders, :extend => :projects do |t|

    end
end
