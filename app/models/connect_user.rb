class ConnectUser < ActiveRecord::Base
	include ActionView::Helpers::TextHelper
	attr_accessible :first_name, :last_name, :phone, :email, :worklist_item_id, :report_id, :checklist_item_id

	belongs_to :worklist_item
	belongs_to :checklist_item
	belongs_to :report

	def text_task(task)
        clean_phone
        @account_sid = 'AC9876d738bf527e6b9d35af98e45e051f'
        @auth_token = '217b868c691cd7ec356c7dbddb5b5939'
        twilio_phone = "14157234334"
        @client = Twilio::REST::Client.new(@account_sid, @auth_token)
        truncated_task = truncate(task.body, length:15)
        puts "should be sending a task text, \"#{truncated_task}\", to #{full_name} at phone: #{phone}"
        @client.account.sms.messages.create(
            :from => "+1#{twilio_phone}",
            :to => phone,
            :body => "You've been assigned a task on BuildHawk: \"#{truncated_task}\". Click here to view: https://www.buildhawk.com/task/#{task.id}"
        )
    end

	acts_as_api

	api_accessible :user do |t|
		#t.add :id
		t.add :first_name
		t.add :last_name
		t.add :phone
		t.add :email
	end
end
