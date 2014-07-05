class Reminder < ActiveRecord::Base
	require 'resque'
	attr_accessible :user_id, :checklist_item_id, :project_id, :reminder_datetime, :email, :text, :push, :active

	belongs_to :user
	belongs_to :checklist_item
	belongs_to :project
	belongs_to :worklist_item

	validates_presence_of :reminder_datetime
	after_commit :schedule, on: :create
	before_destroy :unschedule

	default_scope { order('reminder_datetime') }

	def schedule
		Activity.create(
			:checklist_item_id => checklist_item_id,
			:worklist_item_id => worklist_item_id,
			:project_id => project_id,
			:user_id => user_id,
			:activity_type => self.class.name,
			:body => "#{user.full_name} just set a reminder for #{reminder_datetime.strftime("%b%e,%l:%M %p")}."
		)
		Resque.enqueue_at(reminder_datetime, SetReminder, id)
	end

	def unschedule
		if checklist_item
			Activity.where(:activity_type => self.class.name, :checklist_item_id => checklist_item_id, :user_id => user_id).each do |a| a.destroy end
		elsif worklist_item
			Activity.where(:activity_type => self.class.name, :worklist_item_id => worklist_item_id, :user_id => user_id).each do |a| a.destroy end
		end
		Resque.remove_delayed(SetReminder,id)
	end

	def reminder_date
		reminder_datetime.to_i
	end

	acts_as_api

	api_accessible :projects do |t|
		t.add :id
		t.add :user
		t.add :checklist_item_id
		t.add :reminder_date
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

    api_accessible :checklists, :extend => :projects do |t|
      
    end

    api_accessible :details, :extend => :projects do |t|
      
    end

    api_accessible :dashboard, :extend => :projects do |t|
      
    end

end