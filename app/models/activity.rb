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

end
