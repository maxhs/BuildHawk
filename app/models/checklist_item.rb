class ChecklistItem < ActiveRecord::Base
	attr_accessible :body, :complete, :item_type, :completed_by_user, :completed_by_user_id, :subcategory_id, :subcategory, :status, :critical_date, :completed_date,
                    :photos, :photos_attributes, :checklist_id, :checklist, :order_index
  	
  	belongs_to :subcategory, :counter_cache => true
    belongs_to :category, :counter_cache => true
    belongs_to :checklist, :counter_cache => true
    belongs_to :completed_by_user, :class_name => "User"
  	has_many :photos
  	has_many :comments, :dependent => :destroy

    default_scope { order('id') }

    after_commit :check_completed

    accepts_nested_attributes_for :photos, :allow_destroy => true#, :reject_if => lambda { |c| c[:image_file_name].blank? }

  	acts_as_api

    def subcategory_name
      subcategory.name
    end

    def category_name
      subcategory.category.name
    end

    def check_completed
      if status == "Completed" && completed_date == nil
        self.update_attribute :completed_date, Date.today
        if subcategory.completed_count != 0 && subcategory.completed_count == subcategory.item_count
          puts "marking subcategory completed"
          subcategory.update_attribute :completed_date, Date.today
        end
        #TODO create a completed notification

      elsif status != "Completed" && completed_date != nil
        puts "should be getting rid of completed date"
        self.update_attributes :completed_date => nil, :completed_by_user => nil
      end
    end

  	api_accessible :projects do |t|
  		t.add :id
      t.add :body
  		t.add :critical_date
  		t.add :completed_date
  		t.add :status
      t.add :subcategory_name
      t.add :category_name
      t.add :photos
      t.add :comments
  	end

    api_accessible :checklist, :extend => :projects do |t|

    end

    api_accessible :dashboard, :extend => :projects do |t|

    end

end