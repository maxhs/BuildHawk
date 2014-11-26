class Notification < ActiveRecord::Base

	attr_accessible :user_id, :comment_id, :read, :sent, :checklist_item_id, :task_id, :report_id, 
					:body, :notification_type, :project_id, :feed, :message_id

	belongs_to :user
	belongs_to :target_user, :class_name => "User"
	belongs_to :project
	belongs_to :report
	belongs_to :task
	belongs_to :checklist_item
	belongs_to :comment
	belongs_to :message

	after_create :deliver

	def deliver
		if user && user.push_permissions
			puts "Should be sending a push to: #{user.full_name}"
			user.notify_all_devices(
		        :alert          	=> body, 
		        :report_id 			=> report_id, 
		        :task_id 			=> task_id,
		        :checklist_item_id 	=> checklist_item_id,
		        :comment_id 		=> comment_id,
		        :project_id 		=> project_id,
		        :message_id 		=> message_id,
		        :badge          	=> user.notifications.where(read: false).count
		    )
			self.update_column :sent, true
		end
	end 

	def created_date
        created_at.to_i
    end

    def epoch_time
		created_at.to_i
	end
   
	acts_as_api

	api_accessible :notifications do |t|
		t.add :id
		t.add :created_date
		t.add :epoch_time
		t.add :report_id
		t.add :task_id
		t.add :project_id
		t.add :checklist_item_id
		t.add :comment
		t.add :message
		t.add :notification_type
		t.add :read
	end

	api_accessible :details, :extend => :notifications do |t|

    end
end
