class Reminder < ActiveRecord::Base
	attr_accessible :user_id, :checklist_item_id, :project_id, :reminder_datetime, :email, :text, :push, :active

	belongs_to :user
	belongs_to :checklist_item
	belongs_to :project

	after_create :schedule
	before_destroy :unschedule

	def schedule

	end

	def unschedule

	end

	acts_as_api


	api_accessible :projects do |t|
		t.add :id
		t.add :user
		t.add :checklist_item
		t.add :reminder_datetime
		t.add :email
		t.add :text
		t.add :push
		t.add :active
	end

	api_accessible :user, :extend => :projects do |t|
      
    end

    api_accessible :company, :extend => :projects do |t|
      
    end

    api_accessible :worklist, :extend => :projects do |t|
      
    end

    api_accessible :checklist, :extend => :projects do |t|
      
    end

    api_accessible :details, :extend => :projects do |t|
      
    end
    api_accessible :detail, :extend => :projects do |t|
      
    end

end