class Photo < ActiveRecord::Base
	attr_accessible :image, :user_id, :project_id, :company_id, :image_file_name, :source, :report_id, :checklist_item_id,
					:worklist_item_id, :phase, :name, :folder_id, :description, :mobile

	belongs_to :user
	belongs_to :project
	belongs_to :report
	belongs_to :company
	belongs_to :worklist_item, counter_cache: true
	belongs_to :checklist_item, counter_cache: true
	belongs_to :folder

	has_many :activities
    
  	has_attached_file 	:image, 
	                    :styles => { :large => ["1024x1024", :jpg],
	                                 :medium  => ["640x640", :jpg],
	                                 :small  => ["200x200#", :jpg],
	                                 :thumb  => ["100x100#", :jpg]
	                     },
	                    :storage        => :s3,
	                    :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
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

	acts_as_api

	def log_activity(user)
		activities.create(
			:user_id => user.id,
			:project_id => project_id,
			:photo_id => id,
			:activity_type => self.class.name,
			:body => "#{user.full_name} added a document."
		)
	end

	def url_medium
		if image_file_name
			image.url(:medium)
		else
			""
		end
	end

	def url_small
		if image_file_name
			image.url(:small)
		else
			""
		end
	end

	def url_thumb
		if image_file_name
			image.url(:thumb)
		else
			""
		end
	end

	def url_large
		if image_file_name
			image.url(:large)
		else
			""
		end
	end

	def original
		if image_file_name
			image.url(:original)
		else
			""
		end
	end

	def user_name
		unless user.nil?
			user.full_name
		else 
			""
		end 
	end

	def date_string
		if report
			report.created_at.to_date
		elsif worklist_item
			worklist_item.created_at.to_date
		else
			created_at.to_date	
		end
	end

	def created_date
		date_string
	end

	def assignee
		worklist_item.assignee.full_name if worklist_item && worklist_item.assignee
	end

	def has_assignee?
		!worklist_item_id.nil?
	end

	def has_folder?
		folder.present?
	end

	def folder_name
		folder.name
	end

	def epoch_time
      	created_at.to_i
	end

	api_accessible :dashboard do |t|
		t.add :id
		t.add :epoch_time	
		t.add :original
		t.add :url_large
		t.add :url_medium
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
		t.add :date_string
		t.add :description
		t.add :folder, :if => :has_folder?
		## deprecated
		t.add :folder_name, :if => :has_folder?
		t.add :folder_id, :if => :has_folder?
		##
	end

	api_accessible :item, :extend => :dashboard do |t|

	end

	api_accessible :projects, :extend => :dashboard do |t|

	end

	api_accessible :checklists, :extend => :dashboard do |t|

	end

	api_accessible :worklist, :extend => :dashboard do |t|

	end

	api_accessible :reports, :extend => :dashboard do |t|

	end

	api_accessible :details, :extend => :dashboard do |t|

	end

	api_accessible :notifications, :extend => :dashboard do |t|

	end

	api_accessible :reminders, :extend => :dashboard do |t|

	end

	api_accessible :connect, :extend => :dashboard do |t|

	end
end
