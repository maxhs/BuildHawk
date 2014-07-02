class Comment < ActiveRecord::Base
    
	attr_accessible :body, :user_id, :report_id, :checklist_item_id, :worklist_item_id, :mobile, :message_id
  	belongs_to :user
  	belongs_to :report
  	belongs_to :checklist_item, counter_cache: true
  	belongs_to :worklist_item, counter_cache: true
    belongs_to :message
    has_one :notification, dependent: :destroy
  	has_many :photos
    has_one :activity, dependent: :destroy

    validates_presence_of :body
    validates :body, :length => { :minimum => 1 }
    default_scope { order('created_at') }

    after_commit :notify, on: :create

    def project
        if report
            report.project
        elsif checklist_item
            checklist_item.checklist.project
        elsif worklist_item
            worklist_item.worklist.project
        elsif message
            message.target_project
        end
    end

    def notify
        activity.create(
            :user_id => user_id,
            :body => "\"#{body}\"",
            :checklist_item_id => checklist_item_id,
            :report_id => report_id,
            :worklist_item_id => worklist_item_id,
            :message_id => message_id,
            :project_id => project.id, 
            :comment_id => id,
            :activity_type => self.class.name
        )
        puts "just created a comment activity" if activity.save

        if report && report.author
            report.author.notifications.where(
                :body => body, 
                :report_id => report_id,
                :comment_id => id,
                :notification_type => self.class.name
            ).first_or_create
        elsif worklist_item
            worklist_item.user.notifications.where(
                :body => body, 
                :worklist_item_id => worklist_item_id,
                :comment_id => id,
                :notification_type => self.class.name
            ).first_or_create
        end
    end

  	acts_as_api

  	api_accessible :user do |t|

  	end

  	api_accessible :projects do |t|
        t.add :id
        t.add :body
        t.add :user
        t.add :created_at
  	end

  	api_accessible :dashboard, :extend => :projects do |t|

  	end

    api_accessible :checklists, :extend => :projects do |t|

    end

    api_accessible :details, :extend => :projects do |t|

    end

    api_accessible :worklist, :extend => :projects do |t|

    end

    api_accessible :reports, :extend => :projects do |t|

    end
end
