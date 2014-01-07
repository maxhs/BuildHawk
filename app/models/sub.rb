class Sub < ActiveRecord::Base
	attr_accessible :name, :company_id, :company, :email, :phone_number, :count, :punchlist_item_id,
                  :punchlist_item, :image, :image_file_name, :contact_name
  	belongs_to :company
    belongs_to :punchlist_item

    has_attached_file :image, 
                  :styles => { :medium => ["600x600#", :jpg],
                               :small  => ["200x200#", :jpg],
                               :thumb  => ["100x100#", :jpg]
                   },
                  :storage        => :s3,
                  :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
                  :url            => "buildhawk.s3.amazonaws.com",
                  :path           => "sub_image_:id_:style.:extension"

  	acts_as_api

  	api_accessible :report do |t|
      	t.add :id
      	t.add :name
      	t.add :email
      	t.add :phone_number
        t.add :count
  	end

    api_accessible :user, :extend => :report do |t|

    end

    api_accessible :projects, :extend => :report do |t|

    end

    api_accessible :detail, :extend => :report do |t|

    end

    api_accessible :punchlist, :extend => :report do |t|

    end

    api_accessible :checklist, :extend => :report do |t|

    end
end
