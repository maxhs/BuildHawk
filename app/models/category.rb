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
      subcategories.joins(:checklist_items).where(:checklist_items => {:status => "Completed"}).count
    end

  	acts_as_api

  	api_accessible :projects do |t|
  		t.add :name
  		t.add :index
  		t.add :milestone
  		t.add :completed_date
  	end
end
