class User < ActiveRecord::Base
    attr_accessible :first_name, :last_name, :user_id, :email, :password, :phone_number, :push_permissions, :email_permissions,
    				:full_name, :company_id, :company_attributes, :image, :image_file_name, :password_confirmation, :admin, :uber_admin,
            :authentication_token

    belongs_to :company
    
  	has_many :project_users, :dependent => :destroy
  	has_many :projects, :through => :project_users 
    has_many :report_users, :dependent => :destroy
    has_many :reports, :through => :report_users

    has_many :apn_registrations, :dependent => :destroy

  	devise :database_authenticatable, :registerable, :recoverable, :trackable, :token_authenticatable #, :rememberable

  	accepts_nested_attributes_for :company, :allow_destroy => true

    has_attached_file :image, 
                      :styles => { :medium => ["600x600#", :jpg],
                                   :small  => ["200x200#", :jpg],
                                   :thumb  => ["100x100#", :jpg]
                       },
                      :storage        => :s3,
                      :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
                      :url            => "buildhawk.s3.amazonaws.com",
                      :path           => "photo_image_:id_:style.:extension"

    validates_presence_of :first_name
    validates_presence_of :last_name
    validates_presence_of :email
    validates_uniqueness_of :email
    validates_confirmation_of :password
    validates_presence_of :password, :if => :password_required?

    after_create :ensure_full_name
    after_update :ensure_full_name

    def ensure_full_name
      unless full_name.length > 0
        self.update_attribute :full_name, "#{first_name} #{last_name}"
      end
    end
    
    def password_required?
      password.present?
    end

    def coworkers
      without_me = company.users.where("id != ?",self.id)
      without_me.map{|user| {:full_name => user.full_name, :email => user.email, :phone_number => user.phone_number, :id => user.id, :url100 => user.url100}}
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
	    t.add :phone_number
      t.add :authentication_token
      t.add :coworkers
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
      t.add :phone_number
    end

    api_accessible :checklist do |t|
      t.add :first_name
      t.add :full_name
      t.add :email
      t.add :phone_number
      t.add :id
    end

    api_accessible :detail, :extend => :checklist do |t|

    end
end
