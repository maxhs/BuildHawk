class Phase < ActiveRecord::Base
    include ActionView::Helpers::NumberHelper
	attr_accessible :name, :checklist_id, :order_index, :milestone_date, :completed_date, :categories_attributes
  	belongs_to :checklist
  	has_many :categories, :dependent => :destroy
  	accepts_nested_attributes_for :categories, :allow_destroy => true

    after_create :order_indices

    acts_as_list scope: :checklist, column: :order_index
    default_scope { order('order_index') }

    def item_count
        categories.joins(:checklist_items).count if categories
    end

    def completed_count
        categories.joins(:checklist_items).where(:checklist_items => {:state => 1}).count if categories
    end

    def not_applicable_count 
        categories.joins(:checklist_items).where(:checklist_items => {:state => -1}).count if categories
    end

    def progress_percentage
      if item_count > 0
        number_to_percentage((completed_count+not_applicable_count)/item_count.to_f*100,:precision=>1)
      else
        "N/A"
      end
    end

    def progress_count
        not_applicable_count + completed_count
    end

    def order_indices
        sub_index = 0
        categories.sort_by{|c|c.name.to_i}.each do |i|
            i.update_attribute :order_index, sub_index
            sub_index += 1
        end
    end

  	acts_as_api

  	api_accessible :projects do |t|
      t.add :id
  		t.add :name
  		t.add :milestone_date
  		t.add :completed_date
      t.add :item_count
      t.add :completed_count
      t.add :progress_count
      t.add :order_index
      t.add :checklist_id
  	end

    api_accessible :details, :extend => :projects do |t|

    end

    api_accessible :checklists do |t|
      t.add :id
      t.add :categories
      t.add :name
      t.add :completed_date
      t.add :milestone_date
      t.add :progress_percentage
      t.add :order_index
      t.add :checklist_id
    end

    api_accessible :dashboard do |t|
      t.add :id
      t.add :name
      t.add :item_count
      t.add :completed_count
      t.add :progress_count
      t.add :order_index
      t.add :checklist_id
    end
end
