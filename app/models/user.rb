class User < ActiveRecord::Base
    include ActionView::Helpers::NumberHelper

    attr_accessible :first_name, :last_name, :user_id, :email, :password, :phone_number, :push_permissions, :email_permissions,
    				:full_name, :company_id, :company_attributes, :image, :image_file_name, :password_confirmation, :admin, :uber_admin,
                    :authentication_token, :company_admin

    belongs_to :company
    
  	has_many :project_users, :dependent => :destroy
  	has_many :projects, :through => :project_users 
    has_many :report_users, :dependent => :destroy
    has_many :reports, :through => :report_users
    has_many :notifications, :dependent => :destroy
    has_many :apn_registrations, :dependent => :destroy

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

    validates_presence_of :first_name
    validates_presence_of :last_name
    validates_presence_of :email
    validates_uniqueness_of :email
    validates_confirmation_of :password
    validates_presence_of :password, :if => :password_required?

    after_create :welcome

    def full_name
      "#{first_name} #{last_name}"
    end
    
    def welcome
      UserMailer.welcome(self).deliver if self.email 
    end

    def clean_phone_number
      self.phone_number = self.phone_number.gsub(/[^0-9a-z ]/i, '').gsub(/\s+/,'')
      self.save
    end

    def formatted_phone
      if self.phone_number && self.phone_number.length > 0
        clean_phone_number if self.phone_number.include?(' ')
        number_to_phone(self.phone_number, area_code:true)
      end
    end

    def password_required?
      password.present?
    end

    def coworkers
      company.users.map{|user| {:full_name => user.full_name, :email => user.email, :formatted_phone => user.formatted_phone, :phone_number => user.phone_number, :id => user.id, :url100 => user.url100}}
    end

    def url500
      if image_file_name
        image.url(:medium)
      end
    end

    def url200
      if image_file_name
        image.url(:small)
      end
    end

    def url100
      if image_file_name
        image.url(:small)
      end
    end

    def notify_all_devices(options)
      apn_registrations.map{|r| r.token}.each do |token|
        puts "should be sending a push to #{token}"
        APN.notify_async token, options
      end
    end

    def subcontractors
      company.subs
    end

  	acts_as_api

  	api_accessible :user do |t|
        t.add :id
	    t.add :first_name
	    t.add :last_name
	    t.add :full_name
	    t.add :email
	    t.add :formatted_phone
        #get rid of phone number soon
        t.add :phone_number
        t.add :authentication_token
        t.add :coworkers
        t.add :subcontractors
        t.add :company
        t.add :url100
        t.add :url200
  	end

  	api_accessible :feed do |t|
	
  	end

    api_accessible :projects, :extend => :user do |t|

    end

    api_accessible :dashboard, :extend => :user do |t|

    end

    api_accessible :punchlist do |t|
      t.add :first_name
      t.add :full_name
      t.add :email
      t.add :formatted_phone
      #get rid of phone number soon
      t.add :phone_number
    end

    api_accessible :checklist do |t|
      t.add :first_name
      t.add :full_name
      t.add :email
      t.add :formatted_phone
      #get rid of phone number soon
      t.add :phone_number
      t.add :id
    end

    api_accessible :detail, :extend => :checklist do |t|

    end

    api_accessible :report do |t|
      t.add :id
      t.add :first_name
      t.add :last_name
      t.add :full_name
      t.add :email
      t.add :formatted_phone
      #get rid of phone number soon
      t.add :phone_number
    end
end
