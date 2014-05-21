class Company < ActiveRecord::Base
    require 'stripe'

	attr_accessible :name, :phone_number, :email, :photo_attributes, :pre_register, :contact_name, :image, :image_file_name,
                    :customer_token
  
    has_many :users, :dependent => :destroy
    has_many :subs, :dependent => :destroy
    has_many :projects, :dependent => :destroy
	has_many :photos, :dependent => :destroy
	has_many :checklists, :dependent => :destroy
    has_many :charges
    has_many :project_groups, :dependent => :destroy
    has_many :safety_topics, :dependent => :destroy
    has_many :company_subs, :dependent => :destroy
    has_many :subcontractors, :through => :company_subs, :source => :subcontractor

    validates_uniqueness_of :name
	accepts_nested_attributes_for :photos, :allow_destroy => true
  
    has_attached_file :image, 
                  :styles => { :medium => ["600x600#", :jpg],
                               :small  => ["200x200#", :jpg],
                               :thumb  => ["100x100#", :jpg]
                   },
                  :storage        => :s3,
                  :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
                  :url            => "buildhawk.s3.amazonaws.com",
                  :path           => "company_image_:id_:style.:extension"
                  
    validates_attachment :image, :content_type => { :content_type => /\Aimage/ }

    def balance
        charges.where(:paid => false).map(&:amount).flatten.inject(:+)
    end

    def personnel
        return users.map(&:full_name) + subs.map(&:name)
    end

	acts_as_api

  	api_accessible :company do |t|
  		t.add :id
  		t.add :name
  		t.add :projects
        t.add :users
        t.add :subs
        t.add :subcontractors
  	end

  	api_accessible :projects do |t|
  		t.add :id
        t.add :name
  	end

    api_accessible :subs do |t|
        t.add :id
        t.add :name
        t.add :subcontractors
    end

    api_accessible :user, :extend => :projects do |t|
      
    end

    api_accessible :login, :extend => :projects do |t|
      
    end

    api_accessible :report, :extend => :projects do |t|
      
    end
    api_accessible :details, :extend => :projects do |t|
      
    end

    api_accessible :dashboard do |t|
    
    end

    api_accessible :punchlist, :extend => :projects do |t|
        
    end
end
