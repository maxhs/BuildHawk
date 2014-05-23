class Comment < ActiveRecord::Base
	  attr_accessible :body, :user_id, :report_id, :checklist_item_id, :punchlist_item_id, :mobile
  	belongs_to :user
  	belongs_to :report
  	belongs_to :checklist_item, counter_cache: true
  	belongs_to :punchlist_item, counter_cache: true
  	has_many :photos

    validates_presence_of :body
    validates :body, :length => { :minimum => 1 }
    default_scope { order('created_at') }

  	acts_as_api

  	api_accessible :user do |t|

  	end

  	api_accessible :projects do |t|
      t.add :id
      t.add :body
      t.add :user
      t.add :created_at
  	end

  	api_accessible :dashboard, :extend => :projects do |t|

  	end

    api_accessible :checklist, :extend => :projects do |t|

    end

    api_accessible :detail, :extend => :projects do |t|

    end

    api_accessible :punchlist, :extend => :projects do |t|

    end

    api_accessible :report, :extend => :projects do |t|

    end
end
