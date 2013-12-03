class Photo < ActiveRecord::Base
	attr_accessible :image, :user_id, :user, :project_id, :project, :company_id, :image_file_name

	belongs_to :user
	belongs_to :project
	belongs_to :company
    
  	has_attached_file :image, 
                    :styles => { :large => ["1000x1000#", :jpg],
                    			 :medium => ["500x500#", :jpg],
                                 :thumb  => ["200x200#", :jpg]
                     },
                    :storage        => :s3,
                    :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
                    :url            => "buildhawk-images.s3.amazonaws.com",
                    :path           => "photo_image_:id_:style.:extension"
end
