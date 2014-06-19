class Sub < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
	attr_accessible :name, :company_id, :company, :email, :phone, :count, :worklist_item_id,
                  :worklist_item, :image, :image_file_name, :contact_name
  	belongs_to :company
    belongs_to :worklist_item

    after_save :clean_phone
    before_destroy :clean_up

    def clean_up
        ReportSub.where(:sub_id => id).destroy_all
        WorklistItem.where(:sub_assignee_id => id).each do |i|
            puts "cleaning up worklist item: #{i.id}"
            i.update_attribute :sub_assignee_id, nil
        end
    end

    def clean_phone
        if phone && phone.include?(' ')
            self.phone = phone.gsub(/[^0-9a-z ]/i, '').gsub(/\s+/,'')
            self.save
        end
    end

    def formatted_phone
      if phone && self.phone.length > 0
        clean_phone if self.phone.include?(' ')
        number_to_phone(self.phone, area_code:true)
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
      	t.add :phone
        t.add :count
  	end

    api_accessible :user, :extend => :report do |t|

    end

    api_accessible :projects, :extend => :report do |t|

    end

    api_accessible :detail, :extend => :report do |t|

    end

    api_accessible :worklist, :extend => :report do |t|

    end

    api_accessible :checklist, :extend => :report do |t|

    end
    
    api_accessible :login, :extend => :report do |t|

    end

    api_accessible :company, :extend => :report do |t|

    end

    api_accessible :details do |t|

    end
end
