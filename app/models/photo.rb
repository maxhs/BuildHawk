class Photo < ActiveRecord::Base
	attr_accessible :image, :user_id, :user, :project_id, :project, :company_id, :image_file_name, :source, :report_id, :checklist_item_id,
					:punchlist_item_id, :phase, :name, :punchlist_item, :report, :folder

	belongs_to :user
	belongs_to :project
	belongs_to :report
	belongs_to :company
	belongs_to :punchlist_item, counter_cache: true
	belongs_to :checklist_item, counter_cache: true
    
  	has_attached_file 	:image, 
	                    :styles => { :large => ["2048x2048#", :jpg],
	                                 :small  => ["200x200#", :jpg],
	                                 :thumb  => ["100x100#", :jpg]
	                     },
	                    :storage        => :s3,
	                    :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
	                    :url            => "buildhawk.s3.amazonaws.com",
	                    :path           => "photo_image_:id_:style.:extension"

	acts_as_api

	def url200
		if image_file_name
			image.url(:small)
		end
	end

	def url100
		if image_file_name
			image.url(:thumb)
		end
	end

	def url_large
		if image_file_name
			image.url(:large)
		end
	end

	def original
		if image_file_name
			image.url(:original)
		end
	end

	def user_name
		user.full_name if user
	end

	def created_date
		if report
			report.created_at.to_date
		elsif punchlist_item
			punchlist_item.created_at.to_date
		else
			created_at.to_date	
		end
	end

	def assignee
		if punchlist_item.assignee
			punchlist_item.assignee.full_name
		elsif punchlist_item.sub_assignee
			punchlist_item.sub_assignee.name
		end
	end

	def has_assignee?
		punchlist_item_id.present?
	end

	api_accessible :dashboard do |t|
		t.add :id
		t.add :url_large
		t.add :original
		t.add :url200
		t.add :url100
		t.add :image_file_size
		t.add :image_content_type
		t.add :source
		t.add :phase
		t.add :created_at
		t.add :user_name
		t.add :name
		t.add :created_date
		t.add :folder
		t.add :assignee, :if => :has_assignee?
	end

	api_accessible :item, :extend => :dashboard do |t|

	end

	api_accessible :projects, :extend => :dashboard do |t|

	end

	api_accessible :checklist, :extend => :dashboard do |t|

	end

	api_accessible :punchlist, :extend => :dashboard do |t|

	end

	api_accessible :detail, :extend => :dashboard do |t|

	end

	api_accessible :report, :extend => :dashboard do |t|

	end
end
