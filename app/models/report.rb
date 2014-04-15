class Report < ActiveRecord::Base
	attr_accessible :title, :report_type, :body, :author_id, :project_id, :report_fields, :weather, :photos_attributes, 
                  :users_attributes, :report_users_attributes, :users, :user_ids, :created_date, :subs, :sub_ids, :subs_attributes,
                  :report_subs_attributes, :weather_icon, :temp, :wind, :precip, :humidity, :precip_accumulation, :mobile
  	
    belongs_to :author, :class_name => "User"
  	belongs_to :project
  	has_many :comments, :dependent => :destroy
  	has_many :report_fields, :dependent => :destroy
    has_many :report_users, :dependent => :destroy
    has_many :users, :through => :report_users
    has_many :report_subs, :dependent => :destroy
    has_many :subs, :through => :report_subs
    has_many :photos, :dependent => :destroy
    has_many :safety_topics, :dependent => :destroy

    validates_presence_of :report_type
    validates_presence_of :created_date

    accepts_nested_attributes_for :users, :allow_destroy => true
    accepts_nested_attributes_for :subs, :allow_destroy => true
    accepts_nested_attributes_for :report_subs
    accepts_nested_attributes_for :photos, :allow_destroy => true, :reject_if => lambda { |c| c[:image].blank? }

    #websolr
    searchable do
      text    :body
      text    :weather
      text    :created_date
      integer :project_id
      text    :users do
        users.map(&:full_name)
      end
      time    :created_at
    end

    def possible_types
      ["Daily","Safety","Weekly"]
    end

    def date_for_sort
      if created_date && created_date.length > 0
        Date.strptime(created_date,"%m/%d/%Y")
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

    def possible_topics
        company_topics = SafetyTopic.where(:company_id => project.company.id) if project.company
        if company_topics
             return company_topics
        else
            return SafetyTopic.where("company_id IS NULL").uniq 
        end
    end 

  	acts_as_api

  	api_accessible :report do |t|
        t.add :id
        t.add :author
        t.add :created_at
        t.add :updated_at
        t.add :created_date
  		t.add :title
  		t.add :report_type
  		t.add :body
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
        t.add :personnel
        t.add :safety_topics
        t.add :possible_topics
  	end
end
