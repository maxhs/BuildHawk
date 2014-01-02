class Sub < ActiveRecord::Base
	attr_accessible :name, :company_id, :company, :email, :phone_number, :count, :punchlist_item_id,
                    :punchlist_item
  	belongs_to :company
    belongs_to :punchlist_item
  	has_many :users

  	acts_as_api

  	api_accessible :report do |t|
      	t.add :id
      	t.add :name
      	t.add :email
      	t.add :phone_number
        t.add :count
  	end

    api_accessible :user, :extend => :report do |t|

    end
end
