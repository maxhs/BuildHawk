class Category < ActiveRecord::Base
	  attr_accessible :name, :checklist_id, :index, :milestone_date, :completed_date, :subcategories_attributes
  	belongs_to :checklist
  	has_many :subcategories
    has_many :checklist_items, :dependent => :destroy
  	accepts_nested_attributes_for :subcategories, :allow_destroy => true

    after_create :assign_items

    def item_count
      if checklist_items.count > 0
        checklist_items.count
      else
        subcategories.joins(:checklist_items).count
      end
    end

    def completed_count
      if checklist_items.count > 0
        checklist_items.where(:status => "Completed").count
      else
        subcategories.joins(:checklist_items).where(:checklist_items => {:status => "Completed"}).count if subcategories
      end
    end

    def assign_items
      checklist_items << subcategories.map(&:checklist_items).flatten
    end

  	acts_as_api

  	api_accessible :projects do |t|
  		t.add :name
  		t.add :index
  		t.add :milestone
  		t.add :completed_date
  	end

    api_accessible :checklist do |t|
      t.add :subcategories
      t.add :name
      t.add :completed_date
      t.add :milestone_date
    end

    api_accessible :dashboard do |t|
      t.add :name
      t.add :item_count
      t.add :completed_count
    end
end
