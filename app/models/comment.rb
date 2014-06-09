class Comment < ActiveRecord::Base
    include ActionView::Helpers::TextHelper
	attr_accessible :body, :user_id, :report_id, :checklist_item_id, :worklist_item_id, :mobile
  	belongs_to :user
  	belongs_to :report
  	belongs_to :checklist_item, counter_cache: true
  	belongs_to :worklist_item, counter_cache: true
    has_one :notification, dependent: :destroy
  	has_many :photos

    validates_presence_of :body
    validates :body, :length => { :minimum => 1 }
    default_scope { order('created_at') }

    after_create :notify

    def notify
        if report && report.author
            truncated = truncate(body, length:20)
            report.author.notifications.where(
                :message => "#{user.full_name} just commented on your #{report.report_type} Report from #{report.created_date}: \"#{truncated}\"", 
                :report_id => report_id,
                :comment_id => id,
                :notification_type => "Comment"
            ).first_or_create
        elsif worklist_item
            truncated_item = truncate(worklist_item.body, length:20)
            truncated = truncate(body, length:20)
            worklist_item.user.notifications.where(
                :message => "#{user.full_name} just commented on your worklist item (#{truncated_item.strip}) \"#{truncated}\"", 
                :worklist_item_id => worklist_item_id,
                :comment_id => id,
                :notification_type => "Comment"
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

    api_accessible :checklist, :extend => :projects do |t|

    end

    api_accessible :detail, :extend => :projects do |t|

    end

    api_accessible :worklist, :extend => :projects do |t|

    end

    api_accessible :report, :extend => :projects do |t|

    end
end
