class Photo < ActiveRecord::Base
	attr_accessible :image, :user_id, :project_id, :company_id, :image_file_name, :source, :report_id, :checklist_item_id,
					:task_id, :phase, :name, :folder_id, :description, :mobile, :comment_id

	belongs_to :user
	belongs_to :project
	belongs_to :report
	belongs_to :company
	belongs_to :task, counter_cache: true
	belongs_to :checklist_item, counter_cache: true
	belongs_to :folder
	belongs_to :comment

	has_many :activities
    
    if Rails.env.production?
    	host_alias = "dw9f6h00eoolt.cloudfront.net"
    else
    	host_alias = "d2bs59u537xlvu.cloudfront.net"
    end

  	has_attached_file 	:image, 
	                    :styles => { :large => ["1024x1024", :jpg],
	                                 :medium  => ["640x640", :jpg],
	                                 :small  => ["200x200#", :jpg],
	                                 :thumb  => ["100x100#", :jpg]
	                     },
	                    :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
	                    :storage        => :s3,
	                    :url 			=> ":s3_alias_url",
	                   	:s3_host_alias 	=> host_alias,
	                    :s3_protocol 	=> :https,
	                    :path           => "photo_image_:id_:style.:extension"
	                    
	validates_attachment :image, :content_type => { :content_type => [/\Aimage/, "application/pdf"] }
	#process_in_background :image, :only_process => lambda { |a| a.instance.mobile? ? [:thumb, :small, :medium, :large] : [] }

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
		elsif task
			task.created_at.to_date
		else
			created_at.to_date	
		end
	end

	def created_date
		date_string
	end

	def assignee
		task.assignee.full_name if task && task.assignee
	end

	def has_assignee?
		!task_id.nil?
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

	api_accessible :tasklist, :extend => :dashboard do |t|

	end

	api_accessible :reports, :extend => :dashboard do |t|

	end

	api_accessible :v3_reports, :extend => :reports do |t|

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
