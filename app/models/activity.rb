class Activity < ActiveRecord::Base
	attr_accessible :user_id, :project_id, :worklist_item_id, :checklist_item_id, :report_id, :comment_id, :body,
					:hidden

	belongs_to :user
	belongs_to :project
	belongs_to :worklist_item
	belongs_to :checklist_item
	belongs_to :report
	belongs_to :comment
end
