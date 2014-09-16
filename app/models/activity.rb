class Activity < ActiveRecord::Base
	attr_accessible :user_id, :project_id, :task_id, :checklist_item_id, :report_id, :comment_id, :body,
					:hidden, :activity_type, :message_id, :photo_id

	belongs_to :user
	belongs_to :project
	belongs_to :task
	belongs_to :checklist_item
	belongs_to :report
	belongs_to :comment
	belongs_to :message
	belongs_to :photo

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

	def worklist_id
		worklist_item.worklist.id if worklist_item
	end

	def worklist_item
		task
	end

	def worklist_item_id
		task.id
	end

	acts_as_api

	api_accessible :dashboard do |t|
		t.add :id
		t.add :user_id
		t.add :checklist_id
		t.add :checklist_item
		t.add :report
		t.add :comment
		t.add :worklist_id
		t.add :worklist_item
		t.add :tasklist_id
		t.add :task
		t.add :project_id
		t.add :body
		t.add :hidden
		t.add :created_date
		t.add :activity_type
		t.add :photo
	end

	api_accessible :user, :extend => :dashboard do |t|
      
    end

    api_accessible :company, :extend => :dashboard do |t|
      
    end

    api_accessible :projects, :extend => :dashboard do |t|
      
    end

    api_accessible :notifications, :extend => :projects do |t|

    end

    api_accessible :details do |t|
      	t.add :id
		t.add :user_id
		t.add :checklist_id
		t.add :checklist_item_id
		t.add :report_id
		t.add :comment
		t.add :worklist_item_id
		t.add :task_id
		t.add :project_id
		t.add :body
		t.add :hidden
		t.add :created_date
		t.add :activity_type
    end

    api_accessible :reports, :extend => :details do |t|
      
    end

    api_accessible :tasklist, :extend => :details do |t|
      
    end

    api_accessible :checklists, :extend => :details do |t|
      
    end
end
