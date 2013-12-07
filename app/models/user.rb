class User < ActiveRecord::Base
    attr_accessible :first_name, :last_name, :user_id, :email, :password, :phone_number, :push_permissions, :email_permissions,
    				:full_name, :company_id, :company_attributes, :photos_attributes

    belongs_to :company
  	has_many :project_users
  	has_many :projects, :through => :project_users 
    has_many :report_personnel
    has_many :reports, :through => :report_personnel 
    has_many :photos

  	devise :database_authenticatable, :registerable, :recoverable, :trackable, :validatable#, :rememberable

  	accepts_nested_attributes_for :company
    accepts_nested_attributes_for :photos

    after_create :ensure_full_name

    def ensure_full_name
      unless full_name.length > 0
        puts "ensuring full name"
        self.update_attribute :full_name, (first_name + ' ' + last_name)
      end
    end

  	acts_as_api

  	api_accessible :user do |t|
	    t.add :first_name
	    t.add :last_name
	    t.add :full_name
	    t.add :email
	    t.add :address
	    t.add :phone_number
	    t.add :company
	    t.add :projects
	    t.add :company
  	end

  	api_accessible :feed do |t|
	
  	end
end
