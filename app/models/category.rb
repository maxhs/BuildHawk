class Category < ActiveRecord::Base
	  attr_accessible :name, :checklist_id, :index, :milestone_date, :completed_date, :subcategories_attributes
  	belongs_to :checklist
    belongs_to :core_checklist
  	has_many :subcategories
  	accepts_nested_attributes_for :subcategories

    def item_count
      subcategories.joins(:checklist_items).count
    end

    def completed_count
      subcategories.joins(:checklist_items).where(:checklist_items => {:status => "Completed"}).count if subcategories
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
