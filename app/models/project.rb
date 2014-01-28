class Project < ActiveRecord::Base
    include ActionView::Helpers::NumberHelper
	  attr_accessible :name, :company_id, :active, :users, :address_attributes, :users_attributes, :projects_users_attributes, :checklist, :photos,
                    :user_ids, :core
  	
  	has_many :project_users, :dependent => :destroy
  	has_many :users, :through => :project_users 
  	
  	belongs_to :company
  	has_one :address
  	has_many :punchlists, :dependent => :destroy
    has_many :photos, :dependent => :destroy
    has_many :reports, :dependent => :destroy
  	has_one :checklist, :dependent => :destroy
    has_many :folders, :dependent => :destroy

    accepts_nested_attributes_for :address, :allow_destroy => true
    accepts_nested_attributes_for :users, :allow_destroy => true

    # websolr
    searchable do
      text    :name
      text    :address do
        address.formatted_address
      end
      integer :company_id
      time    :created_at
    end

    def checklist_items
      checklist.checklist_items
    end

    def add_punchlist
      punchlists.create
    end

    def upcoming_items
      checklist.upcoming_items if checklist
    end

    def recently_completed
      checklist.recently_completed if checklist
    end

    def progress
      number_to_percentage(checklist.completed_count*100/checklist.item_count.to_f, :precision => 1) if checklist
    end

    def recent_documents
        photos.where("image_file_name IS NOT NULL").last(8)
    end

    def categories
        checklist.categories if checklist
    end

    def has_checklist?
      checklist.present?
    end

    def has_categories?
      !categories.nil?
    end

    def background_destroy
      Resque.enqueue(DestroyProject,id)
    end

    def recent_feed
      limit = 5
      feed = []
      feed += ChecklistItem.where(:checklist_id => checklist.id).order('updated_at DESC').limit(limit)
      feed += Report.where(:project_id => id).order('updated_at DESC').limit(limit)
      feed += PunchlistItem.where(:punchlist_id => punchlists.first.id).order('updated_at DESC').limit(limit) if punchlists && punchlists.first
      feed += Photo.where(:project_id => id).order('updated_at DESC').limit(limit)
      return feed.flatten.sort_by(&:updated_at).reverse.first(5)
    end

    acts_as_api

  	api_accessible :projects do |t|
      t.add :id
  		t.add :name
  		t.add :address
  		t.add :company
  		t.add :punchlists
      t.add :active
  	end

    api_accessible :user do |t|
      t.add :name
      t.add :address
    end

    api_accessible :dashboard do |t|
      t.add :progress, :if => :has_checklist?
      t.add :upcoming_items
      t.add :recently_completed, :if => :has_checklist?
      t.add :recent_documents, :if => :has_checklist?
      t.add :categories, :if => :has_categories?
    end
end
