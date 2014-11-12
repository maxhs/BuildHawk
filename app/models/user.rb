class User < ActiveRecord::Base
    include ActionView::Helpers::NumberHelper

    attr_accessible :first_name, :last_name, :user_id, :email, :password, :push_permissions, :email_permissions, :phone,
    				:company_id, :company_attributes, :image, :image_file_name, :password_confirmation, :admin, :uber_admin, 
                    :authentication_token, :company_admin, :text_permissions, :active, :avatar_url

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
    has_many :tasks, foreign_key: "assignee_id"

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
                      :s3_protocol => :https,
                      :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
                      :url            => "buildhawk.s3.amazonaws.com",
                      :path           => "user_image_:id_:style.:extension"

    validates_attachment :image, :content_type => { :content_type => /\Aimage/ }
    validates_presence_of :first_name, :if => :is_active?
    validates_presence_of :last_name, :if => :is_active?
    validates_presence_of :email, :if => :is_active?
    validates_uniqueness_of :email
    validates_confirmation_of :password, :if => :password_required?
    validates_presence_of :password, :if => :password_required?
    validates_presence_of :company_id

    after_create :welcome
    before_destroy :cleanup_user

    def welcome
        #UserMailer.welcome(self).deliver if email 
        full_name
    end

    def cleanup_user
        Task.where(user_id: id).each do |t|
            t.update_attribute :user_id, nil
        end
    end

    def is_active?
        active
    end

    def full_name 
        if first_name.length > 0 && last_name.length > 0
            full_name = "#{first_name} #{last_name}"
        elsif first_name && first_name.length > 0
            full_name = "#{first_name}"
        else
            full_name = email
        end
        self.update_column :full_name, full_name
        return full_name
    end

    def email_task(task)
        puts "Sending a task email to a user with email: #{email}. Is the user active? #{active}"
        task_array = []
        task_array << task
        TasklistMailer.export(email, task_array, task.tasklist.project).deliver
    end

    def text_task(task)
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
    rescue Twilio::REST::RequestError => e
        puts e.message
    end

    def connect_tasks(project)
        if project
            Task.where(:assignee_id => id).map{|t| t if t.tasklist.project.id == project.id && t.tasklist.project.company.id != company_id}.compact
        else
            Task.where(:assignee_id => id).map{|t| t if t.tasklist.project && t.tasklist.project.company && t.tasklist.project.company.id != company_id}.compact if company_id
        end
    end

    def clean_phone(phone_string)
        phone_string.gsub(/[^0-9a-z ]/i, '').gsub(/\s+/,'')
    end

    def formatted_phone
        number_to_phone(phone, area_code:true) if phone && phone.length > 0
    end

    def password_required?
        password.present? && active?
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

    def cost(company,month)
        days_in_month = Time.days_in_month(Time.now.month,Time.now.year)
        beginning_of_month = Time.now.beginning_of_month
        end_of_month = Time.now.end_of_month
        count = company.billing_days.where("created_at > ? and created_at < ?",beginning_of_month, end_of_month).map{|b| b if b.project_user.user.id == id}.count
        puts "#{full_name} cost count: #{count}"
        puts "monthly calc: #{days_in_month}"
        return 20.to_f/days_in_month*count
    end

    def billable_days(company,month)
        beginning_of_month = Time.now.beginning_of_month
        end_of_month = Time.now.end_of_month
        count = company.billing_days.where("created_at > ? and created_at < ?",beginning_of_month, end_of_month).map{|b| b if b.project_user.user.id == id}.count
        return count
    end

    def notify_all_devices(options)
        push_tokens.each do |push_token|
            if push_token.device_type == 3
                notify_android(options, push_token.token)
            else
                notify_ios(options, push_token.token)
            end
        end
    end

    def notify_ios(options,token)
        require 'houston'

        apn = Houston::Client.production
        apn.certificate = File.read("#{Rails.root}/config/certs/apn_production.pem")
        notification = Houston::Notification.new(device: token)
        notification.alert = options[:alert]
        notification.badge = options[:badge]
        notification.custom_data = options
        apn.push(notification)
    end

    def notify_android(options, token)
        require 'gcm'
        if token && token.length > 0
            ## project name: buildhawk-1
            ## project ID: 149110570482
            data = {
                message: options[:alert],
                task_id: options[:task_id],
                checklist_item_id: options[:checklist_item_id],
                report_id: options[:report_id],
                project_id: options[:project_id],
                unread_messages: options[:badge]
            }
            gcm = GCM.new("AIzaSyDbRNKm1bztoL_w3SNBZ8JCJh-LC_UQsVc")
            options = {data: data}
            response = gcm.send([token], options)
            #puts "GCM response: #{response}"
        end
    end

    def remove_push_tokens_except(device_type,token)
        ## 1 for iPhone, 2 for iPad, 3 for Android
        tokens_for_type = push_tokens.where(device_type: device_type)
        
        tokens_for_type.each do |t|
            t.destroy unless t.token == token
        end

        if push_tokens.count > 0
            return true
        else
            return false
        end
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
        t.add :active
        t.add :authentication_token
        t.add :mobile_token
  	end

    api_accessible :login, :extend => :user do |t|
        t.add :coworkers
        t.add :text_permissions
        t.add :email_permissions
        t.add :push_permissions
        t.add :url_medium
        t.add :alternates
    end

    api_accessible :projects, :extend => :user do |t|
        
    end

    api_accessible :visible_projects, :extend => :projects do |t|
        
    end

    api_accessible :details, :extend => :user do |t|

    end

    api_accessible :v3_details, :extend => :user do |t|

    end

    api_accessible :tasklist, :extend => :user do |t|
      
    end

    api_accessible :connect, :extend => :user do |t|
      
    end

    api_accessible :dashboard, :extend => :user do |t|

    end

    api_accessible :notifications, :extend => :user do |t|

    end

    api_accessible :checklists, :extend => :tasklist do |t|
        
    end

    api_accessible :reports, :extend => :tasklist do |t|
        
    end
    
    api_accessible :v3_reports, :extend => :tasklist do |t|
        
    end

    api_accessible :company, :extend => :tasklist do |t|

    end

    api_accessible :reminders, :extend => :tasklist do |t|

    end

    #private

    def reset_authentication_token
        begin
            self.authentication_token = SecureRandom.hex
        end while self.class.exists?(authentication_token: self.authentication_token)
    end

    def reset_mobile_token
        begin
            self.mobile_token = SecureRandom.hex
        end while self.class.exists?(mobile_token: self.mobile_token)
        self.save
    end
end
