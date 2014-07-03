class Alternate < ActiveRecord::Base
	attr_accessible :user_id, :email, :phone
	belongs_to :user

	acts_as_api

  	api_accessible :user do |t|
		t.add :id
		t.add :user_id
		t.add :email
		t.add :phone
	end

	api_accessible :login, :extend => :user do |t|

	end

end
