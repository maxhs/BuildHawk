class ChecklistItem < ActiveRecord::Base
	attr_accessible :body, :complete, :item_type, :completed_by_user, :completed_by_user_id, :subcategory_id, :subcategory, 
                  :status, :critical_date, :completed_date,:photos, :photos_attributes, :checklist_id, :checklist, 
                  :order_index, :item_index, :photos_count, :comments_count
  	
  	belongs_to :subcategory
    belongs_to :checklist
    belongs_to :completed_by_user, :class_name => "User"
  	has_many :photos
  	has_many :comments, :dependent => :destroy

    default_scope { order('item_index') }

    after_commit :check_completed

    accepts_nested_attributes_for :photos, :reject_if => lambda { |c| c[:image].blank? }

    # websolr
    searchable do
      text    :body
      #text    :item_type
      #text    :status
      integer :checklist_id
    end

  	acts_as_api

    def subcategory_name
      subcategory.name if subcategory
    end

    def types
      ["S&C","Doc","Com"]
    end

    def category_name
      subcategory.category.name if subcategory && subcategory.category
    end

    def check_completed
      if status == "Completed" && completed_date == nil
        self.update_attribute :completed_date, Date.today
        if subcategory.completed_count != 0 && subcategory.completed_count == subcategory.item_count
          subcategory.update_attribute :completed_date, Date.today
        end
        #TODO create a completed notification

      elsif status != "Completed" && completed_date != nil
        self.update_attributes :completed_date => nil, :completed_by_user => nil
      end
    end

    def project_id
      if checklist
        checklist.project.id
      else
        subcategory.category.checklist.project.id
      end
    end

  	api_accessible :projects do |t|
  		t.add :id
        t.add :body
  		t.add :critical_date
  		t.add :completed_date
  		t.add :status
        t.add :item_type
        t.add :photos_count
        t.add :comments_count
  	end

    api_accessible :checklist, :extend => :projects do |t|

    end

    api_accessible :dashboard, :extend => :projects do |t|
      
    end

    api_accessible :detail, :extend => :projects do |t|
        t.add :photos
        t.add :comments
        t.add :category_name
        t.add :project_id
    end

    protected
 
    def resque_solr_update
        Resque.enqueue(SolrUpdate, self.class.to_s, id)
    end

    def resque_solr_remove
        Resque.enqueue(SolrRemove, self.class.to_s, id)
    end

end