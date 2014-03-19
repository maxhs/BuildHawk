class Sub < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
	attr_accessible :name, :company_id, :company, :email, :phone_number, :count, :punchlist_item_id,
                  :punchlist_item, :image, :image_file_name, :contact_name
  	belongs_to :company
    belongs_to :punchlist_item

    after_save :clean_phone_number
    before_destroy :clean_up

    default_scope { order('name ASC') }

    def clean_up
        ReportSub.where(:sub_id => id).destroy_all
        PunchlistItem.where(:sub_assignee_id => id).each do |i|
            puts "cleaning up punchlist item: #{i.id}"
            i.update_attribute :sub_assignee_id, nil
        end
    end

    def clean_phone_number
        if phone_number && phone_number.include?(' ')
            self.phone_number = phone_number.gsub(/[^0-9a-z ]/i, '').gsub(/\s+/,'')
            self.save
        end
    end

    def formatted_phone
      if self.phone_number && self.phone_number.length > 0
        clean_phone_number if self.phone_number.include?(' ')
        number_to_phone(self.phone_number, area_code:true)
      end
    end

    has_attached_file :image, 
                  :styles => { :medium => ["600x600#", :jpg],
                               :small  => ["200x200#", :jpg],
                               :thumb  => ["100x100#", :jpg]
                   },
                  :storage        => :s3,
                  :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
                  :url            => "buildhawk.s3.amazonaws.com",
                  :path           => "sub_image_:id_:style.:extension"

    validates_attachment :image, :content_type => { :content_type => /\Aimage/ }
  	
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
    
    api_accessible :login, :extend => :report do |t|

    end
end
