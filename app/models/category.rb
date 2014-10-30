class Category < ActiveRecord::Base
    include ActionView::Helpers::NumberHelper
	attr_accessible :name, :phase_id, :order_index, :milestone_date, :completed_date, :checklist_items, :state
  	belongs_to :phase
  	has_many :checklist_items, :dependent => :destroy

    after_commit :check_completed, :if => :persisted?
    after_create :order_indices

    acts_as_list scope: :phase, column: :order_index
    default_scope { order('order_index') }

    def order_indices
        if checklist_items.count > 0 && checklist_items.first.order_index.nil?
            checklist_items.each_with_index do |i,idx|
                i.update_attribute :order_index, idx
            end
        end
    end

    def item_count
        checklist_items.count
    end

    def completed_count
        checklist_items.where(state: 1).count if checklist_items
    end

    def check_completed
        if phase.completed_count != 0 && phase.completed_count == phase.item_count
            phase.update_column :completed_date, Date.today
            self.update_columns completed_date: Date.today, state: 1 
        else
            self.update_columns completed_date: nil, state: nil
            phase.update_column :completed_date, nil

        end
    end

    def not_applicable_count 
        checklist_items.where(:state => -1).count if checklist_items
    end

    def progress_percentage
        number_to_percentage((completed_count+not_applicable_count)/item_count.to_f*100,:precision=>1)
    end

  	acts_as_api

  	api_accessible :projects do |t|
        t.add :id
  		t.add :name
  		t.add :category_id
        t.add :phase_id
  		t.add :milestone_date
  		t.add :completed_date
        t.add :order_index
  	end

    api_accessible :checklists do |t|
        t.add :id
        t.add :name
        #t.add :completed_date
        #t.add :milestone_date
        t.add :progress_percentage
        t.add :not_applicable_count
        t.add :completed_count
        t.add :order_index
        t.add :checklist_items
    end

    api_accessible :v3_checklists do |t|
        t.add :id
        t.add :name
        t.add :order_index
        t.add :checklist_items
        #t.add :completed_date
        #t.add :milestone_date
    end

    api_accessible :categories, :extend => :v3_checklists do |t|
        
    end
end
