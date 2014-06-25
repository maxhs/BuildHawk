class ConnectUser < ActiveRecord::Base
	attr_accessible :first_name, :last_name, :phone, :email, :worklist_item_id, :report_id, :checklist_item_id

	belongs_to :worklist_item
	belongs_to :checklist_item
	belongs_to :report

end
