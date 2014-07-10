class Company < ActiveRecord::Base
    require 'stripe'

	attr_accessible :name, :phone, :email, :photo_attributes, :pre_register, :contact_name, :image, :image_file_name,
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
    #has_many :subcontractors, :through => :company_subs, :source => :subcontractor
    has_many :connect_users, :dependent => :destroy

    validates_presence_of :name
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

    before_destroy :clean_company_subs

    def clean_company_subs
        CompanySub.where(:subcontractor_id => id).destroy_all
    end

    def balance
        charges.where(:paid => false).map(&:amount).flatten.inject(:+)
    end

    def personnel
        return users.map(&:full_name) + subs.map(&:name)
    end

    def users_count
        users.count
    end

    def formatted_phone
        if phone && phone.length > 0
            clean_phone if phone.include?(' ')
            number_to_phone(phone, area_code:true)
        end
    end

    def clone_company_subs
        companies_array = []
        subs.each do |s|
            new_company = Company.where(:name => s.name).first_or_create
            new_company.update_attributes :email => s.email, :phone => s.phone if s.email && s.phone
            companies_array << new_company
        end
        companies_array.each do |c|
            company_subs.create :subcontractor_id => c.id
        end
    end

    def subcontractors
        company_subs.sort_by!{|s|s.name.downcase}
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

  	api_accessible :login do |t|
  		t.add :id
        t.add :name
  	end

    api_accessible :user, :extend => :login do |t|
        
    end

    api_accessible :notifications, :extend => :login do |t|
        
    end
    
    api_accessible :projects, :extend => :login do |t|
        t.add :users
        t.add :subcontractors
    end
    
    api_accessible :messages, :extend => :login do |t|
      
    end
    
    api_accessible :reports do |t|
        t.add :id
        t.add :name
        t.add :users
        t.add :subcontractors
    end
    
    api_accessible :details, :extend => :login do |t|
      
    end

    api_accessible :worklist, :extend => :login do |t|
        
    end

    api_accessible :checklists, :extend => :login do |t|
        
    end
    
    api_accessible :dashboard do |t|
    
    end

   
end
