class User < ActiveRecord::Base
    attr_accessible :first_name, :last_name, :user_id, :email, :password, :phone_number, :push_permissions, :email_permissions,
    				:full_name, :company_id

    belongs_to :company
  	has_many :project_users
  	has_many :projects, :through => :project_users 

  	devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

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
