class Activity < ActiveRecord::Base
	attr_accessible :user_id, :project_id, :worklist_item_id, :checklist_item_id, :report_id, :comment_id, :body,
					:hidden, :activity_type, :message_id

	belongs_to :user
	belongs_to :project
	belongs_to :worklist_item
	belongs_to :checklist_item
	belongs_to :report
	belongs_to :comment
	belongs_to :message

	default_scope { order('created_at DESC') }
	after_create :notify

	def notify
		puts "just created an activty"
	end

	def created_date
		created_at.to_i
	end

	def checklist_id
		checklist_item.checklist.id if checklist_item
	end

	acts_as_api

	api_accessible :projects do |t|
		t.add :id
		t.add :user_id
		t.add :checklist_item_id
		t.add :checklist_id
		t.add :report_id
		t.add :comment
		t.add :worklist_item_id
		t.add :project_id
		t.add :body
		t.add :hidden
		t.add :created_date
		t.add :activity_type
	end

	api_accessible :user, :extend => :projects do |t|
      
    end

    api_accessible :company, :extend => :projects do |t|
      
    end

    api_accessible :worklist, :extend => :projects do |t|
      
    end

    api_accessible :checklists, :extend => :projects do |t|
      
    end

    api_accessible :details, :extend => :projects do |t|
      
    end

    api_accessible :dashboard, :extend => :projects do |t|
      
    end
    
    api_accessible :reports, :extend => :projects do |t|
      
    end

    api_accessible :notifications, :extend => :projects do |t|

    end
end
