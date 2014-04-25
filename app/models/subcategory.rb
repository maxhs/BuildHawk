class Subcategory < ActiveRecord::Base
    include ActionView::Helpers::NumberHelper
	attr_accessible :name, :category_id, :order_index, :milestone_date, :completed_date, :checklist_items, :status
  	belongs_to :category
  	has_many :checklist_items, :dependent => :destroy

    after_save :check_completed
    after_create :order_indices

    acts_as_list scope: :category, column: :order_index
    default_scope { order('order_index') }

    def item_count
        checklist_items.count
    end

    def completed_count
        checklist_items.where(:status => "Completed").count if checklist_items
    end

    def check_completed
        if category.completed_count != 0 && category.completed_count == category.item_count
            category.update_attribute :completed_date, Date.today
            status = "Completed"
        elsif completed_date != nil
            completed_date = nil
            status = nil
        end
    end

    def order_indices
        if checklist_items.count > 0 && checklist_items.first.order_index.nil?
            checklist_items.each_with_index do |i,idx|
                i.update_attribute :order_index, idx
            end
        end
    end

    def not_applicable_count 
        checklist_items.where(:status => "Not Applicable").count if checklist_items
    end

    def progress_percentage
        number_to_percentage((completed_count+not_applicable_count)/item_count.to_f*100,:precision=>1)
    end

  	acts_as_api

  	api_accessible :projects do |t|
        t.add :id
  		t.add :name
  		t.add :category_id
  		t.add :milestone_date
  		t.add :completed_date
  	end

    api_accessible :checklist do |t|
        t.add :checklist_items
        t.add :name
        t.add :completed_date
        t.add :milestone_date
        t.add :progress_percentage
    end
end
