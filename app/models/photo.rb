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
end
