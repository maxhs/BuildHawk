class User < ActiveRecord::Base
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::TextHelper

    attr_accessible :first_name, :last_name, :full_name, :user_id, :email, :password, :push_permissions, :email_permissions, :phone,
    				:company_id, :company_attributes, :image, :image_file_name, :password_confirmation, :admin, 
                    :uber_admin, :authentication_token, :company_admin, :text_permissions

    belongs_to :company
  	has_many :project_users, :dependent => :destroy
  	has_many :projects, :through => :project_users
    has_many :report_users, :dependent => :destroy
    has_many :reports, :through => :report_users
    has_many :notifications, :dependent => :destroy
    has_many :apn_registrations, :dependent => :destroy
    has_many :message_users, :dependent => :destroy, autosave: true
    has_many :messages, :through => :message_users , autosave: true

    has_many :photos

    has_many :reminders, :dependent => :destroy
    has_many :alternates, :dependent => :destroy
    has_many :activities#, :dependent => :destroy

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
        if first_name.length && last_name.length
            "#{first_name} #{last_name}"
        elsif first_name.length
            "#{first_name}"
        else
            email
        end
    end

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

    def clean_phone        
        phone = phone.gsub(/[^0-9a-z ]/i, '').gsub(/\s+/,'')
        self.save
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
      company.users.map{|user| {:full_name => user.full_name,:first_name => user.first_name,:last_name => user.last_name, :email => user.email, :formatted_phone => user.formatted_phone, :phone => user.phone, :id => user.id, :url_thumb => user.url_thumb}}
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
        apn_registrations.map{|r| r.token}.each do |token|
            APN.notify_async token, options
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
  	end

    api_accessible :login, :extend => :user do |t|
        t.add :coworkers
        t.add :text_permissions
        t.add :email_permissions
        t.add :push_permissions
        t.add :authentication_token
        t.add :admin
        t.add :company_admin
        t.add :uber_admin
        t.add :url_medium
        t.add :alternates
    end

  	api_accessible :feed do |t|
	
  	end

    api_accessible :projects, :extend => :user do |t|
        
    end

    api_accessible :details, :extend => :user do |t|

    end

    api_accessible :worklist, :extend => :user do |t|
      
    end

    api_accessible :dashboard, :extend => :user do |t|

    end

    api_accessible :notifications, :extend => :user do |t|

    end

    api_accessible :worklist do |t|
        t.add :id
        t.add :first_name
        t.add :last_name
        t.add :full_name
        t.add :email
        t.add :phone
    end

    api_accessible :checklists, :extend => :worklist do |t|
        
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
