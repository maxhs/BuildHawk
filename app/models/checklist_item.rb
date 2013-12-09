class ChecklistItem < ActiveRecord::Base
	attr_accessible :body, :complete, :item_type, :user_id, :subcategory_id, :subcategory, :status, :critical_date, :completed_date
  	
  	belongs_to :subcategory
    belongs_to :category
    belongs_to :checklist
  	has_many :photos
  	has_many :comments

    after_commit :check_completed

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
        #TODO create a completed notification

      elsif status != "Completed" && completed_date != nil
        self.update_attribute :completed_date, nil
      end
    end

  	api_accessible :project do |t|
  		t.add :title
  		t.add :body
  		t.add :critical_date
  		t.add :completed_date
  		t.add :subcategory_id
  		t.add :status
  		t.add :complete
      t.add :subcategory_name
      t.add :category_name
  	end

end