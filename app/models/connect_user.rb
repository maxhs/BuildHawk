class ConnectUser < ActiveRecord::Base
	include ActionView::Helpers::TextHelper
	attr_accessible :first_name, :last_name, :phone, :email, :company_id, :company_name

	has_many :worklist_items
    has_many :project_users, dependent: :destroy
    belongs_to :company

	def email_task(task)
		puts "Sending a worklist item email to a connect user with email: #{email}"
		task_array = []
		task_array << task
		WorklistMailer.export(email, task_array, task.worklist.project).deliver
	end

	def text_task(task)
        clean_phone
        account_sid = 'AC9876d738bf527e6b9d35af98e45e051f'
        auth_token = '217b868c691cd7ec356c7dbddb5b5939'
        twilio_phone = "14157234334"
        client = Twilio::REST::Client.new(account_sid, auth_token)
        truncated_task = truncate(task.body, length:15)
        puts "should be sending a task text, \"#{truncated_task}\", to #{full_name} at phone: #{phone}"
        client.account.sms.messages.create(
            :from => "+1#{twilio_phone}",
            :to => phone,
            :body => "You've been assigned a task on BuildHawk: \"#{truncated_task}\". Click here to view: https://www.buildhawk.com/task/#{task.id}"
        )
    end

    def clean_phone
        if phone.include?(' ')
            phone = phone.gsub(/[^0-9a-z ]/i, '').gsub(/\s+/,'')
            self.save
        end
    end

    def formatted_phone
      	if phone && phone.length > 0
        	clean_phone if phone.include?(' ')
        	number_to_phone(phone, area_code:true)
      	end
    end

    def full_name
    	if first_name && first_name.length
            if last_name && last_name.length
                "#{first_name} #{last_name}"
            else
                "#{first_name}"
            end
        elsif email
            email
        else
        	""
        end
    end

	acts_as_api

	api_accessible :user do |t|
		t.add :id
		t.add :first_name
		t.add :last_name
        t.add :full_name 
		t.add :phone
		t.add :email
        t.add :company
	end

    api_accessible :reports, :extend => :user do |t|
        
    end
    api_accessible :details, :extend => :user do |t|
        
    end
    api_accessible :worklist, :extend => :user do |t|
        
    end
    api_accessible :connect, :extend => :user do |t|
        
    end
end
