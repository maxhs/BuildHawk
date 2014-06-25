class Activity < ActiveRecord::Base
	attr_accessible :user_id, :project_id, :worklist_item_id, :checklist_item_id, :report_id, :comment_id, :body,
					:hidden, :activity_type

	belongs_to :user
	belongs_to :project
	belongs_to :worklist_item
	belongs_to :checklist_item
	belongs_to :report
	belongs_to :comment

	acts_as_api

	api_accessible :projects do |t|
		t.add :is
		t.add :user_id
		t.add :checklist_item_id
		t.add :report_id
		t.add :comment_id
		t.add :worklist_item_id
		t.add :body
		t.add :hidden
	end
end
