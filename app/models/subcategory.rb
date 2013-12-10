class Subcategory < ActiveRecord::Base
	attr_accessible :name, :category_id, :index, :milestone_date, :completed_date, :checklist_items
  	belongs_to :category
  	has_many :checklist_items, :dependent => :destroy

    after_save :check_completed

    def item_count
      checklist_items.count
    end

    def completed_count
      checklist_items.where(:status => "Completed").count
    end

    def check_completed
      if category.completed_count == category.item_count
        puts "marking category completed"
        category.update_attribute :completed_date, Date.today
      end
    end

  	acts_as_api

  	api_accessible :project do |t|
  		t.add :name
  		t.add :category_id
  		t.add :index
  		t.add :milestone
  		t.add :completed_date
  	end
end
