class Subcategory < ActiveRecord::Base
	attr_accessible :name, :category_id, :order_index, :milestone_date, :completed_date, :checklist_items
  	belongs_to :category
  	has_many :checklist_items, :dependent => :destroy

    after_save :check_completed
    after_create :order_indices

    def item_count
      checklist_items.count
    end

    def completed_count
      checklist_items.where(:status => "Completed").count if checklist_items
    end

    def check_completed
      if category.completed_count != 0 && category.completed_count == category.item_count
        category.update_attribute :completed_date, Date.today
      end
    end

    def order_indices
      item_index = 0
      checklist_items.each do |i|
        i.update_attribute :order_index, item_index
        item_index+=1
      end
    end

  	acts_as_api

  	api_accessible :projects do |t|
  		t.add :name
  		t.add :category_id
  		t.add :index
  		t.add :milestone_date
  		t.add :completed_date
  	end

    api_accessible :checklist do |t|
      t.add :checklist_items
      t.add :name
      t.add :completed_date
      t.add :milestone_date
    end
end
