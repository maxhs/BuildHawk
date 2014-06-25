class ConnectUser < ActiveRecord::Base
	attr_accessible :first_name, :last_name, :phone, :email, :worklist_item_id, :report_id, :checklist_item_id

	belongs_to :worklist_item
	belongs_to :checklist_item
	belongs_to :report

	acts_as_api

	api_accessible :user do |t|
		#t.add :id
		t.add :first_name
		t.add :last_name
		t.add :phone
		t.add :email
	end
end
