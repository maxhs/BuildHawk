class Reminder < ActiveRecord::Base
	include ActionView::Helpers::TextHelper
	attr_accessible :user_id, :checklist_item_id, :project_id, :reminder_datetime, :email, :text, :push, :active

	belongs_to :user
	belongs_to :checklist_item
	belongs_to :project

	after_create :schedule
	before_destroy :unschedule

	def schedule
		truncated = truncate(checklist_item.body, length:20)
		Activity.create(
			:checklist_item_id => checklist_item_id,
			:project_id => project_id,
			:user_id => user_id,
			:activity_type => self.class.name,
			:body => "#{user.full_name} just set a reminder for #{truncated}: #{reminder_datetime.strftime("%b %e, %l:%M %p")}."
		)

	end

	def unschedule
		Activity.where(:activity_type => self.class.name, :checklist_item_id => checklist_item_id, :user_id => user_id).each do |a| 
			puts "Destroying an activity because we're deleting the Reminder"
			a.destroy 
		end

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

    api_accessible :checklist, :extend => :projects do |t|
      
    end

    api_accessible :details, :extend => :projects do |t|
      
    end

    api_accessible :detail, :extend => :projects do |t|
      
    end

end