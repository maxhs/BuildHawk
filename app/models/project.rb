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

    accepts_nested_attributes_for :address
    accepts_nested_attributes_for :users
    
    after_create :assign_core

    def assign_core
      core = CoreChecklist.last
      new_checklist = Checklist.create
      new_checklist.categories << core.categories
      self.update_attribute :checklist, new_checklist 

      add_punchlist if punchlists.count == 0
    end

    def add_punchlist
      punchlists.create
    end

    def upcoming_items
      checklist.item_array.select{|i| i.critical_date}.sort_by(&:critical_date).last(5)
    end

    def recently_completed
      checklist.item_array.select{|i| i.status == "Completed"}.sort_by(&:completed_date).last(5)
    end

    def progress
      number_to_percentage(checklist.completed_count/checklist.item_count.to_f, :precision => 1)
    end

    def recent_documents
        photos.last(5)
    end
  	
    acts_as_api

  	api_accessible :projects do |t|
        t.add :id
  		t.add :name
  		t.add :address
  		t.add :company
  		t.add :checklist
  		t.add :punchlists
        t.add :active
        t.add :users
  	end

    api_accessible :user do |t|
      t.add :name
      t.add :address
    end

    api_accessible :dashboard do |t|
      t.add :progress
      t.add :upcoming_items
      t.add :recently_completed
      t.add :recent_documents
    end
end
