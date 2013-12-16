class Category < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
	  attr_accessible :name, :checklist_id, :order_index, :milestone_date, :completed_date, :subcategories_attributes, :order_index
  	belongs_to :checklist
  	has_many :subcategories, :dependent => :destroy
    has_many :checklist_items, :dependent => :destroy
  	accepts_nested_attributes_for :subcategories, :allow_destroy => true

    after_create :order_indices

    def item_count
      subcategories.includes(:checklist_items).count if subcategories
    end

    def completed_count
      subcategories.includes(:checklist_items).where(:checklist_items => {:status => "Completed"}).count if subcategories
    end

    def progress_percentage
      items = subcategories.includes(:checklist_items) 
      completed_items = items.where(:checklist_items => {:status => "Completed"})
      number_to_percentage(completed_items.count/items.count.to_f*100,:precision=>1)
    end

    def order_indices
      puts "should be ordering categories"
      sub_index = 0
      subcategories.order('name').each do |i|
        i.update_attribute :order_index, sub_index
        sub_index += 1
      end
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
