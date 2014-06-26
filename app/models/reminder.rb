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

end