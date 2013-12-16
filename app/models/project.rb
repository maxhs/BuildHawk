class Project < ActiveRecord::Base
    include ActionView::Helpers::NumberHelper
	  attr_accessible :name, :company_id, :active, :users, :address_attributes, :users_attributes, :projects_users_attributes, :checklist, :photos,
                    :user_ids
  	
  	has_many :project_users, :dependent => :destroy
  	has_many :users, :through => :project_users 
  	
  	belongs_to :company
  	has_one :address
  	has_many :punchlists, :dependent => :destroy
    has_many :photos, :dependent => :destroy
    has_many :reports, :dependent => :destroy
  	has_one :checklist, :dependent => :destroy

    accepts_nested_attributes_for :address, :allow_destroy => true
    accepts_nested_attributes_for :users, :allow_destroy => true

    def add_punchlist
      punchlists.create
    end

    def upcoming_items
      checklist.item_array.select{|i| i.critical_date}.sort_by(&:critical_date).last(5) if checklist
    end

    def recently_completed
      checklist.item_array.select{|i| i.status == "Completed"}.sort_by(&:completed_date).last(5) if checklist
    end

    def progress
      number_to_percentage(checklist.completed_count*100/checklist.item_count.to_f, :precision => 1) if checklist
    end

    def recent_documents
        photos.where("image_file_name IS NOT NULL").last(5)
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
  	  puts "background destroy"
      Resque.enqueue(DestroyProject,id)
    end

    acts_as_api

  	api_accessible :projects do |t|
      t.add :id
  		t.add :name
  		t.add :address
  		t.add :company
  		t.add :checklist, :if => :has_checklist?
  		t.add :punchlists
      t.add :active
      t.add :users
  	end

    api_accessible :user do |t|
      t.add :name
      t.add :address
    end

    api_accessible :dashboard do |t|
      t.add :progress, :if => :has_checklist?
      t.add :upcoming_items, :if => :has_checklist?
      t.add :recently_completed, :if => :has_checklist?
      t.add :recent_documents, :if => :has_checklist?
      t.add :categories, :if => :has_categories?
    end
end
