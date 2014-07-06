class Report < ActiveRecord::Base
	attr_accessible :title, :report_type, :body, :author_id, :project_id, :report_fields, :weather, :photos_attributes, 
                  :users_attributes, :report_users_attributes, :users, :user_ids, :date_string, :subs, :sub_ids, :subs_attributes,
                  :report_subs_attributes, :weather_icon, :temp, :wind, :precip, :humidity, :precip_accumulation, :mobile,
                  :company_ids, :companies, :report_companies_attributes
  	
    belongs_to :author, :class_name => "User"
  	belongs_to :project
  	has_many :comments, :dependent => :destroy
    has_many :notifications, :dependent => :destroy
  	has_many :report_fields, :dependent => :destroy
    has_many :report_users, :dependent => :destroy
    has_many :users, :through => :report_users
    has_many :report_subs, :dependent => :destroy
    has_many :subs, :through => :report_subs
    has_many :report_companies, :dependent => :destroy
    has_many :companies, :through => :report_companies
    has_many :photos, :dependent => :destroy

    has_many :report_topics, :dependent => :destroy
    has_many :safety_topics, :through => :report_topics

    has_many :activities, :dependent => :destroy
    has_many :connect_users
    
    validates_presence_of :report_type
    validates_presence_of :date_string

    accepts_nested_attributes_for :users, :allow_destroy => true
    accepts_nested_attributes_for :subs, :allow_destroy => true
    accepts_nested_attributes_for :report_companies, :allow_destroy => true
    accepts_nested_attributes_for :report_subs, :allow_destroy => true
    accepts_nested_attributes_for :report_users, :allow_destroy => true
    accepts_nested_attributes_for :photos, :allow_destroy => true, :reject_if => lambda { |c| c[:image].blank? }

    #after_commit :log_activity

    #websolr
    searchable do
        text    :body
        text    :weather
        text    :date_string
        integer :project_id
        text    :users do
            users.map(&:full_name)
        end
        time    :created_at
    end

    def log_activity
        puts "Should be creating a new activity for report: #{date_string}"
        activities.create(
            :project_id => project_id,
            :report_id => id,
            :activity_type => self.class.name,
            #:body => "#{report_type} Report - #{date_string} was updated." 
        )
    end

    def possible_types
        ["Daily","Safety","Weekly"]
    end

    def date_for_sort
        if date_string && date_string.length > 0
            Date.strptime(date_string,"%m/%d/%Y")
        else 
            created_at
        end
    end

    def to_param
        "#{id}-#{(Digest::SHA1.hexdigest id.to_s)[0..4]}"
    end

    def personnel
        report_users + report_subs
    end

    def personnel_count
        count = 0
        report_users.map{|u| count+u.hours if u.hours}
        report_companies.map{|c| count+c.count if c.count}
        count
    end

    def has_body?
        body.present? && body.length > 0
    end

    def epoch_time
        created_at.to_i
    end

    def clone_report_subs
        report_subs.each do |rs|
            puts "Updating #{date_string} for sub: #{rs.sub.name}"
            company = Company.where(:name => rs.sub.name).first
            if company
                puts "found company: #{company.name}"
                company_sub = project.company.company_subs.where(:subcontractor_id => company.id).first
                if company_sub
                    rc = report_companies.where(:company_id => company_sub.subcontractor.id).first_or_create
                    rc.update_attribute :count, rs.count
                else
                    puts "Couldn't find company sub for #{rs.sub.name}"
                end
            end
        end
    end

    def updated_date
        updated_at.to_i
    end

    def created_date
        date_string
    end

  	acts_as_api

  	api_accessible :reports do |t|
        t.add :id
        t.add :author
        t.add :updated_at
        t.add :created_at
        t.add :date_string
        t.add :created_date
  		t.add :title
  		t.add :report_type
        t.add :weather
        t.add :weather_icon
        t.add :precip
        t.add :temp
        t.add :wind
        t.add :humidity
  		t.add :report_fields
        t.add :possible_types
        t.add :comments
        t.add :photos
        t.add :report_users
        t.add :report_companies
        t.add :report_topics
        t.add :body, :if => :has_body?
        t.add :activities
        ### slated for deletion in next version. replace epoch_time with created_date as soon as 1.04 is out ###
        t.add :epoch_time
        t.add :safety_topics
        t.add :report_subs
        t.add :personnel
        ###
  	end

    api_accessible :notifications, :extend => :reports do |t|

    end

    api_accessible :dashboard do |t|
        t.add :id
        t.add :author
        t.add :updated_at
        t.add :created_at
        t.add :date_string
        t.add :created_date
        t.add :title
        t.add :report_type
        t.add :weather
        t.add :weather_icon
        t.add :precip
        t.add :temp
        t.add :wind
        t.add :humidity
        t.add :report_fields
        t.add :possible_types
        t.add :photos
        t.add :body, :if => :has_body?
    end

    api_accessible :projects, :extend => :dashboard do |t|

    end
end
