class Photo < ActiveRecord::Base
	attr_accessible :image, :user_id, :project_id, :company_id, :image_file_name, :source, :report_id, :checklist_item_id,
					:punchlist_item_id, :phase, :name, :folder_id, :description, :mobile

	belongs_to :user
	belongs_to :project
	belongs_to :report
	belongs_to :company
	belongs_to :punchlist_item, counter_cache: true
	belongs_to :checklist_item, counter_cache: true
	belongs_to :folder
    
    before_create :ensure_defaults

  	has_attached_file 	:image, 
	                    :styles => { :large => ["1024x1024#", :jpg],
	                                 :small  => ["200x200#", :jpg],
	                                 :thumb  => ["100x100#", :jpg]
	                     },
	                    :storage        => :s3,
	                    :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
	                    :url            => "buildhawk.s3.amazonaws.com",
	                    :path           => "photo_image_:id_:style.:extension"
	                    
	validates_attachment :image, :content_type => { :content_type => [/\Aimage/, "application/pdf"] }
	#process_in_background :image

	# websolr
    searchable do
        text 	:name, boost: 2.0
        text    :source
        text    :folder do
        	folder.name if folder
        end        
        integer :project_id
        time    :created_at
    end

    #handle_asynchronously :solr_index, queue: 'indexing', priority: 50
  	#handle_asynchronously :solr_index!, queue: 'indexing', priority: 50

	acts_as_api

	def ensure_defaults 
		unless source == "Documents"
			unless name
				self.name = ""
			end
		end
	end

	### slated for deletion ###
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
	###

	def url_small
		if image_file_name
			image.url(:small)
		end
	end

	def url_thumb
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
		user.full_name unless user.nil?
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
		punchlist_item.assignee.full_name if punchlist_item && punchlist_item.assignee
	end

	def folder_name
		folder.name
	end

	def has_assignee?
		!punchlist_item_id.nil?
	end

	def has_folder?
		!folder_id.nil?
	end

	def epoch_time
      	created_at.to_i
	end

	api_accessible :dashboard do |t|
		t.add :id
		t.add :epoch_time
		t.add :original
		t.add :url_large
		t.add :url_small
		t.add :url_thumb
		t.add :image_file_size
		t.add :image_content_type
		t.add :source
		t.add :phase
		t.add :created_at
		t.add :user_name
		t.add :name
		t.add :created_date
		t.add :folder_name, :if => :has_folder?
		t.add :folder_id, :if => :has_folder?
		#t.add :assignee, :if => :has_assignee?
		##slated for removal
		t.add :url200
		t.add :url100
		###
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

	api_accessible :details, :extend => :dashboard do |t|

	end
end
