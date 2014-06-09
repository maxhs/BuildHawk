class Notification < ActiveRecord::Base

	attr_accessible :user_id, :target_user_id, :comment_id, :read, :sent, :checklist_item_id, :punchlist_item_id, 
					:report_id, :message, :notification_type, :project_id, :feed

	belongs_to :user
	belongs_to :target_user, :class_name => "User"
	belongs_to :project
	belongs_to :report
	belongs_to :punchlist_item
	belongs_to :checklist_item
	belongs_to :comment

	after_create :deliver

	def deliver
		if user && user.push_permissions
			puts "Should be sending a push to: #{user.full_name}"
			user.notify_all_devices(
		        :alert          	=> message, 
		        :report_id 			=> report_id, 
		        :punchlist_item_id 	=> punchlist_item_id,
		        :checklist_item_id 	=> checklist_item_id,
		        :comment_id 		=> comment_id,
		        :project_id 		=> project_id,
		        :badge          	=> user.notifications.where(:read => false).count
		    )
			sent = true
			self.save
		end
	end 

	def created_date
        created_at.to_i
    end
    
    def updated_date
        updated_at.to_i if updated_at
    end

	acts_as_api

	api_accessible :notifications do |t|
		t.add :id
		t.add :report_id
		t.add :punchlist_item_id
		t.add :checklist_item_id
		t.add :message
		t.add :created_date
		t.add :updated_date
	end
end
