class User < ActiveRecord::Base
    attr_accessible :first_name, :last_name, :user_id, :email, :password, :phone_number, :push_permissions, :email_permissions,
    				:full_name, :company_id, :company_attributes, :photos_attributes, :password_confirmation, :admin, :uber_admin,
            :authentication_token

    belongs_to :company
    
  	has_many :project_users, :dependent => :destroy
  	has_many :projects, :through => :project_users 
    has_many :report_users, :dependent => :destroy
    has_many :reports, :through => :report_users
    has_many :photos, :dependent => :destroy

    has_many :apn_registrations, :dependent => :destroy

  	devise :database_authenticatable, :registerable, :recoverable, :trackable, :token_authenticatable #, :rememberable

  	accepts_nested_attributes_for :company, :allow_destroy => true
    accepts_nested_attributes_for :photos, :allow_destroy => true

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
      company.users
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
    end
end
