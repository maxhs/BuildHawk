class User < ActiveRecord::Base
    include ActionView::Helpers::NumberHelper

    attr_accessible :first_name, :last_name, :full_name, :user_id, :email, :password, :push_permissions, :email_permissions, :phone,
    				:company_id, :company_attributes, :image, :image_file_name, :password_confirmation, :admin, 
                    :uber_admin, :authentication_token, :company_admin, :text_permissions

    belongs_to :company
  	has_many :project_users, :dependent => :destroy
  	has_many :projects, :through => :project_users
    has_many :report_users, :dependent => :destroy
    has_many :reports, :through => :report_users
    has_many :notifications, :dependent => :destroy
    has_many :push_tokens, :dependent => :destroy
    has_many :message_users, :dependent => :destroy, autosave: true
    has_many :messages, :through => :message_users , autosave: true
    has_many :comments, dependent: :destroy
    has_many :worklist_items, foreign_key: "assignee_id"

    has_many :photos

    has_many :reminders, :dependent => :destroy
    has_many :alternates, :dependent => :destroy
    has_many :activities, :dependent => :destroy

  	devise :database_authenticatable, :registerable, :recoverable, :trackable

  	accepts_nested_attributes_for :company, :allow_destroy => true

    has_attached_file :image, 
                      :styles => { :medium => ["600x600#", :jpg],
                                   :small  => ["200x200#", :jpg],
                                   :thumb  => ["100x100#", :jpg]
                       },
                      :storage        => :s3,
                      :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
                      :url            => "buildhawk.s3.amazonaws.com",
                      :path           => "user_image_:id_:style.:extension"

    validates_attachment :image, :content_type => { :content_type => /\Aimage/ }
    validates_presence_of :first_name
    validates_presence_of :last_name
    validates_presence_of :email
    validates_uniqueness_of :email
    validates_confirmation_of :password, :if => :password_required?
    validates_presence_of :password, :if => :password_required?

    #after_create :welcome
    after_commit :clean_phone, :if => :persisted?
    after_commit :clean_name, :if => :persisted?
    
    def welcome
        UserMailer.welcome(self).deliver if email 
        full_name = "#{first_name} #{last_name}"
        self.save
    end

    def full_name 
        if first_name.length > 0 && last_name.length > 0
            "#{first_name} #{last_name}"
        elsif first_name && first_name.length > 0
            "#{first_name}"
        else
            email
        end
    end

    def email_task(task)
        puts "Sending a task email to a user with email: #{email}"
        task_array = []
        task_array << task
        WorklistMailer.export(email, task_array, task.worklist.project).deliver
    end

    def text_task(task)
        #clean_phone
        account_sid = 'AC9876d738bf527e6b9d35af98e45e051f'
        auth_token = '217b868c691cd7ec356c7dbddb5b5939'
        twilio_phone = "14157234334"
        client = Twilio::REST::Client.new(account_sid, auth_token)
        if task.body && task.body.length > 15
            truncated_task = "#{task.body[0..15]}..."
        else
            truncated_task = task.body
        end
        
        puts "should be sending a task text, \"#{truncated_task}\", to #{full_name} at phone: #{phone}"
        client.account.sms.messages.create(
            :from => "+1#{twilio_phone}",
            :to => phone,
            :body => "You've been assigned a task on BuildHawk: \"#{truncated_task}\". Click here to view: https://www.buildhawk.com/task/#{task.id}"
        )
    end

    def connect_items(project)
        if project
            WorklistItem.where(:assignee_id => id).map{|t| t if t.worklist.project.id == project.id && t.worklist.project.company.id != company_id}.compact
        else
            WorklistItem.where(:assignee_id => id).map{|t| t if t.worklist.project.company.id != company_id}.compact if company
        end
    end

    def clean_phone   
        if phone && phone.length > 0
            phone = phone.gsub(/[^0-9a-z ]/i, '').gsub(/\s+/,'')
            self.save
        end
    end

    def clean_name
        unless full_name == "#{first_name} #{last_name}" 
            self.full_name = "#{first_name} #{last_name}"
            self.save
        end
    end

    def formatted_phone
      if phone && phone.length > 0
        clean_phone if phone.include?(' ')
        number_to_phone(phone, area_code:true)
      end
    end

    def password_required?
      password.present?
    end

    def coworkers
      company.users.map{|user| {:full_name => user.full_name,:first_name => user.first_name,:last_name => user.last_name, :email => user.email, :formatted_phone => user.formatted_phone, :phone => user.phone, :id => user.id, :url_thumb => user.url_thumb}} if company
    end

    def any_admin?
        admin || uber_admin || company_admin
    end

    def url_medium
        if image_file_name
            image.url(:medium)
        else
            ""
        end
    end

    def url_small
        if image_file_name
            image.url(:small)
        else
            ""
        end
    end

    def url_thumb
        if image_file_name
            image.url(:thumb)
        else
            ""
        end
    end

    def notify_all_devices(options)
        puts "options #{options}"
        push_tokens.each do |push_token|
            puts "push token: #{push_token.token}"
            if push_token.device_type == 3
                notify_android(options, push_token.token)
            else
                APN.notify_async push_token.token, options
            end
        end
    end


    def notify_android(options, token)
        ## proejct id: buildhawk-1
        ## project number: 149110570482
        GCM.host = 'https://android.googleapis.com/gcm/send'
        GCM.format = :json
        GCM.key = "AIzaSyAhYb_V2vurBqGPRKD7ONVd_ylKAhXuWxk"
        data = {
            message: options[:alert],
            worklist_item_id: options[:worklist_item_id],
            checklist_item_id: options[:checklist_item_id],
            report_id: options[:report_id],
            project_id: options[:project_id],
            unread_messages: options[:badge]
        }
        puts "android data: #{data} for #{full_name} and token: #{token}"
        GCM.send_notification(token,data)
    end

    def has_company?
        company
    end

  	acts_as_api

  	api_accessible :user do |t|
        t.add :id
        t.add :first_name
        t.add :last_name
        t.add :full_name
        t.add :email
        t.add :phone
        t.add :formatted_phone
        t.add :company
        t.add :url_thumb
        t.add :url_small
        t.add :admin
        t.add :company_admin
        t.add :uber_admin
  	end

    api_accessible :login, :extend => :user do |t|
        t.add :coworkers#, :if => :has_company?
        t.add :text_permissions
        t.add :email_permissions
        t.add :push_permissions
        t.add :authentication_token
        t.add :url_medium
        t.add :alternates
    end

    api_accessible :projects, :extend => :user do |t|
        
    end

    api_accessible :details, :extend => :user do |t|

    end

    api_accessible :worklist, :extend => :user do |t|
      
    end

    api_accessible :connect, :extend => :user do |t|
      
    end

    api_accessible :dashboard, :extend => :user do |t|

    end

    api_accessible :notifications, :extend => :user do |t|

    end

    api_accessible :checklists, :extend => :worklist do |t|
        
    end

    api_accessible :reports, :extend => :worklist do |t|
        
    end

    api_accessible :company, :extend => :worklist do |t|

    end

    api_accessible :reminders, :extend => :worklist do |t|

    end
end
