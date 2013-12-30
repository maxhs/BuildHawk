class Notification < ActiveRecord::Base
	include ActionView::Helpers::TextHelper
	
	attr_accessible :user_id, :user, :target_user_id, :target_user, :read, :sent, :checklist_item_id,
					:checklist_item, :punchlist_item, :punchlist_item_id, :report, :report_id, :message,
					:notification_type

	belongs_to :user
	belongs_to :target_user, :class_name => "User"
	belongs_to :report
	belongs_to :punchlist_item
	belongs_to :checklist_item

	after_create :deliver

	def deliver
		if user.push_permissions
			self.user.notify_all_devices(
		        :alert          	=> self.message, 
		        :report_id 			=> self.report_id, 
		        :punchlist_item_id 	=> self.punchlist_item_id,
		        :checklist_item_id 	=> self.checklist_item_id,
		        :badge          	=> self.user.notifications.where(:read => false).count
		    )
			self.sent = true
		end
	end 

	acts_as_api

	api_accessible :notifications do |t|
		t.add :id
		t.add :report_id
		t.add :punchlist_item_id
		t.add :checklist_item_id
		t.add :message
	end
end
