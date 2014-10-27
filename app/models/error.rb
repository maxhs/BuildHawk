class Error < ActiveRecord::Base
	attr_accessible :user_id, :report_id, :checklist_item_id, :photo_id, :task_id, :message_id. :body, :status_code

	belongs_to :user
	belongs_to :report
	belongs_to :checklist_item
	belongs_to :photo
	belongs_to :task
	belongs_to :message
end
