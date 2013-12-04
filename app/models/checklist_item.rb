class ChecklistItem < ActiveRecord::Base
	attr_accessible :body, :complete, :item_type, :user_id, :subcategory_id, :subcategory, :status, :critical_date, :completed_date
  	
  	belongs_to :subcategory
  	has_many :photos
  	has_many :comments

  	acts_as_api

  	api_accessible :project do |t|
  		t.add :title
  		t.add :body
  		t.add :critical_date
  		t.add :completed_date
  		t.add :subcategory_id
  		t.add :status
  		t.add :complete
  	end

end