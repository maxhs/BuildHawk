class Sub < ActiveRecord::Base
	attr_accessible :name, :company_id, :company, :email, :phone_number
  	belongs_to :company
  	has_many :users

  	acts_as_api

  	api_accessible :report do |t|
      	t.add :id
      	t.add :name
      	t.add :email
      	t.add :phone_number
  	end
end
