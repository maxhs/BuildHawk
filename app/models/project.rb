class Project < ActiveRecord::Base
    
    include ActionView::Helpers::NumberHelper
	attr_accessible :name, :company_id, :active, :users, :address_attributes, :checklist_id, :photos,
                    :user_ids, :core, :project_group_id, :companies, :company_ids, :order_index
  	
  	has_many :project_users, :dependent => :destroy, autosave: true
  	has_many :users, :through => :project_users, autosave: true

    has_many :project_subs, :dependent => :destroy, autosave: true
    has_many :companies, :through => :project_subs, autosave: true
  	
    belongs_to :project_group, counter_cache: true
  	belongs_to :company
  	has_one :address, :dependent => :destroy
  	has_many :tasklists, :dependent => :destroy
    has_many :photos, :dependent => :destroy
    has_many :reports, :dependent => :destroy
  	has_one :checklist, :dependent => :destroy
    has_many :folders, :dependent => :destroy
    has_many :notifications, :dependent => :destroy
    has_many :reminders, :dependent => :destroy
    has_many :activities, :dependent => :destroy

    acts_as_list scope: :project_group_id, column: :order_index

    after_create :default_folders
    after_commit :adjust_users, :if => :persisted?

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

    def hidden_for_user?(current_user)
        project_user = ProjectUser.where(project_id: id, user_id: current_user.id).first
        if project_user && project_user.hidden
            return true
        else
            return false
        end
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

    def duplicate_project
        new_checklist = checklist.dup :include => [:company, {:phases => {:categories => :checklist_items}}], :except => {:phases => {:categories => {:checklist_items => :state}}}
        new_project = self.dup :include => [{:reports => [:comments, :report_users, :users, :photos]}, {:photos => [:user, :checklist_item, :task, :report, :project,:folder]}, {:tasklists => :tasks}, :address, :folders, :users, :project_users]
        new_project.checklist = new_checklist
        new_project.save
        return new_project
    end

    def recent_feed
        limit = 5
        feed = []
        feed += checklist_items.order('updated_at DESC').limit(limit)
        feed += reports.order('updated_at DESC').limit(limit)
        feed += Task.where(:tasklist_id => tasklists.first.id).order('updated_at DESC').limit(limit) if tasklists && tasklists.first
        feed += recent_photos(limit)
        return feed.flatten.sort_by(&:updated_at).compact.reverse.first(limit)
    end

    def recent_photos(limit)
        photos.order('updated_at DESC').limit(limit)
    end

    def recent_activities
        ## default order is DESC, so first makes sense
        activities.first(10) if activities.count
    end

    def most_recent_activities
        activities.first(3) if activities.count
    end

    def background_destroy
        require "resque"
        Resque.enqueue(DestroyProject, id)
    end

    acts_as_api

  	api_accessible :projects do |t|
        t.add :id
  		t.add :name
  		t.add :address
        t.add :active
        t.add :core
        t.add :project_group
        t.add :company
        t.add :users
        t.add :progress
        t.add :reminders
        t.add :order_index
  	end

    api_accessible :tasklist do |t|
        t.add :id
        t.add :name
        t.add :company
        t.add :active
    end

    api_accessible :connect, :extend => :tasklist do |t|
    
    end

    api_accessible :details do |t|
        t.add :id
        t.add :name
        t.add :active
        t.add :address
        t.add :progress
        t.add :company
        t.add :users
        t.add :project_users
        t.add :companies
    end

    api_accessible :v3_details do |t|
        t.add :id
        t.add :name
        t.add :active
        t.add :address
        t.add :progress
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
        t.add :active
    end

    api_accessible :company, :extend => :user do |t|
        
    end

    api_accessible :messages, :extend => :user do |t|
        
    end

    api_accessible :dashboard, :extend => :projects do |t|
        t.add :upcoming_items
        t.add :recently_completed
        t.add :recent_documents
        t.add :phases
        t.add :recent_activities
    end
end
