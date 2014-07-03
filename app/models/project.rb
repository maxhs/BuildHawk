class Project < ActiveRecord::Base
    include ActionView::Helpers::NumberHelper
	  attr_accessible :name, :company_id, :active, :users, :address_attributes, :checklist, :photos,
                        :user_ids, :core, :project_group_id, :companies, :company_ids
  	
  	has_many :project_users, :dependent => :destroy, autosave: true
  	has_many :users, :through => :project_users, autosave: true

    has_many :project_subs, :dependent => :destroy, autosave: true
    has_many :companies, :through => :project_subs , autosave: true
  	
    belongs_to :project_group, counter_cache: true
  	belongs_to :company
  	has_one :address
  	has_many :worklists, :dependent => :destroy
    has_many :photos, :dependent => :destroy
    has_many :reports, :dependent => :destroy
  	has_one :checklist, :dependent => :destroy
    has_many :folders, :dependent => :destroy
    has_many :notifications, :dependent => :destroy
    has_many :reminders, :dependent => :destroy
    has_many :activities, :dependent => :destroy

    after_create :default_folders
    after_commit :adjust_users

    accepts_nested_attributes_for :address, :allow_destroy => true
    accepts_nested_attributes_for :users, :allow_destroy => true
    accepts_nested_attributes_for :companies, :allow_destroy => true

    # websolr
    searchable do
        text    :name
        text    :address do
            address.formatted_address if address
        end
        integer :company_id
        time    :created_at
    end

    def default_folders
        ["Subcontractors","Floor Plans","Permit Docs","Schedule","Selections"].each do |f|
            self.folders.create :name => f
        end
        self.save
    end

    def to_param
        "#{id}-#{(Digest::SHA1.hexdigest id.to_s)[0..4]}"
    end

    def adjust_users
        if project_group_id != nil
            puts 'inside check_groups'
            project_users.each do |pu|
                pu.update_attribute :project_group_id, project_group_id
            end
        else
            puts "erase groups"
            project_users.each do |pu|
                pu.update_attribute :project_group_id, nil
            end
        end
    end

    def checklist_items
        checklist.checklist_items
    end

    def upcoming_items
        checklist.upcoming_items if checklist
    end

    def recently_completed
        checklist.recently_completed if checklist
    end

    def progress
        checklist.progress_percentage if checklist
    end

    def recent_documents
        photos.where("image_file_name IS NOT NULL").last(8).reverse
    end

    def phases
        checklist.phases if checklist
    end

    def ordered_reports
        reports.sort_by{|r| r.date_for_sort}.reverse
    end

    def has_group?
        !project_group_id.nil?
    end

    def duplicate_project
        new_checklist = checklist.dup :include => [:company, {:phases => {:categories => :checklist_items}}], :except => {:phases => {:categories => {:checklist_items => :status}}}
        new_project = self.dup :include => [{:reports => [:comments, :report_users, :users, :photos]}, {:photos => [:user, :checklist_item, :worklist_item, :report, :project,:folder]}, {:worklists => :worklist_items}, :address, :folders, :users, :project_users]
        new_project.checklist = new_checklist
        new_project.save
        return new_project
    end

    def recent_feed
        limit = 5
        feed = []
        feed += checklist_items.order('updated_at DESC').limit(limit)
        feed += Report.where(:project_id => id).order('updated_at DESC').limit(limit)
        feed += WorklistItem.where(:worklist_id => worklists.first.id).order('updated_at DESC').limit(limit) if worklists && worklists.first
        feed += Photo.where(:project_id => id).order('updated_at DESC').limit(limit)
        return feed.flatten.sort_by(&:updated_at).compact.reverse.first(limit)
    end

    def recent_activities
        ## default order is DESC, so first makes sense
        activities.first(3) if activities.count
    end

    ## deprecated
    def categories
        checklist.phases if checklist
    end
    ##

    acts_as_api

  	api_accessible :projects do |t|
        t.add :id
  		t.add :name
  		t.add :address
  		t.add :company
        t.add :active
        t.add :core
        t.add :progress
        t.add :upcoming_items
        t.add :recently_completed
        t.add :recent_documents
        t.add :phases
        t.add :project_group, :if => :has_group?
        t.add :activities
        t.add :reminders
        t.add :users
        ### slated for deletion in 1.04 ###
        t.add :categories
        ###
  	end

    api_accessible :worklist do |t|
        t.add :id
        t.add :name
        t.add :company
    end

    api_accessible :details do |t|
        t.add :id
        t.add :name
        t.add :company
        t.add :users
        t.add :companies
    end

    api_accessible :notifications, :extend => :projects do |t|
        t.add :notifications
    end

    api_accessible :user do |t|
        t.add :id
        t.add :name
        t.add :address
    end

    api_accessible :company, :extend => :user do |t|
        
    end

    api_accessible :messages, :extend => :user do |t|
        
    end

    api_accessible :dashboard do |t|
        t.add :id
        t.add :progress
        t.add :upcoming_items
        t.add :recently_completed
        t.add :recent_documents
        t.add :phases
        ### slated for deletion ###
        t.add :categories
        ###
    end
end
