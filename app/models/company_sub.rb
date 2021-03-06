class CompanySub < ActiveRecord::Base
	include ActionView::Helpers::NumberHelper
	
	attr_accessible :company_id, :subcontractor_id, :subcontractor, :contact_name, :email, :phone
	belongs_to :company
	belongs_to :subcontractor, :class_name => "Company"
	validates_presence_of :subcontractor_id
	validate :not_self

	def not_self
		errors.add(:subcontractor_id, "can't be the same as Company") unless company_id != subcontractor_id
	end

	acts_as_api

	def name
		subcontractor.name if subcontractor
	end

	def users
		subcontractor.users if subcontractor
	end

	def has_subcontractor?
		subcontractor.present?
	end

	def formatted_phone
        number_to_phone(phone, area_code:true) if phone && phone.length > 0
    end

# ## slated for deletion ##
# 	def users_count
# 		subcontractor.users.count if subcontractor
# 	end
# ## ##
	api_accessible :projects do |t|
		t.add :id
		t.add :subcontractor
	end

    api_accessible :reports do |t|
        t.add :id
        t.add :name, :if => :has_subcontractor?
        t.add :users, :if => :has_subcontractor?
        #t.add :users_count, :if => :has_subcontractor?
    end

    api_accessible :tasklist, :extend => :projects do |t|
		
	end
end
