class Photo < ActiveRecord::Base
	attr_accessible :image, :user_id, :user, :project_id, :project, :company_id, :image_file_name, :source, :report_id, :checklist_item_id,
					:punchlist_item_id

	belongs_to :user
	belongs_to :project
	belongs_to :report
	belongs_to :company
	belongs_to :punchlist_item
	belongs_to :checklist_item
    
  	has_attached_file 	:image, 
	                    :styles => { :large => ["1000x1000#", :jpg],
	                    			 :medium => ["500x500#", :jpg],
	                                 :small  => ["200x200#", :jpg],
	                                 :thumb  => ["100x100#", :jpg]
	                     },
	                    :storage        => :s3,
	                    :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
	                    :url            => "buildhawk.s3.amazonaws.com",
	                    :path           => "photo_image_:id_:style.:extension"

	acts_as_api
	
	def url500
		if image_file_name
			image.url(:medium)
		end
	end

	def url200
		if image_file_name
			image.url(:small)
		end
	end

	def url100
		if image_file_name
			image.url(:small)
		end
	end

	def orig
		if image_file_name
			image.url(:original)
		end
	end

	def user_name
		user.full_name if user
	end

	api_accessible :dashboard do |t|
		t.add :orig
		t.add :url500
		t.add :url200
		t.add :url100
		t.add :source
		t.add :created_at
		t.add :user_name
	end

	api_accessible :item, :extend => :dashboard do |t|

	end

	api_accessible :projects, :extend => :dashboard do |t|

	end

	api_accessible :checklist, :extend => :dashboard do |t|

	end

	api_accessible :punchlist, :extend => :dashboard do |t|

	end

end
