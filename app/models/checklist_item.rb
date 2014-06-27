class ChecklistItem < ActiveRecord::Base
	attr_accessible :body, :item_type, :completed_by_user, :completed_by_user_id, :category_id, 
                  :status, :critical_date, :completed_date,:photos, :photos_attributes, :checklist_id, :checklist, 
                  :order_index, :photos_count, :comments_count, :user_id, :reminder_date
  	
  	belongs_to :user
    belongs_to :category
    belongs_to :checklist
    belongs_to :completed_by_user, :class_name => "User"
  	has_many :photos
  	has_many :comments, :dependent => :destroy
    has_many :notifications, :dependent => :destroy
    has_many :reminders, :dependent => :destroy
    has_many :activities, :dependent => :destroy
    acts_as_list scope: :category, column: :order_index
    default_scope { order('order_index') }

    after_commit :log_activity

    accepts_nested_attributes_for :photos, :reject_if => lambda { |c| c[:image].blank? }

    if Rails.env.production?
      # websolr
      searchable auto_index: false, auto_remove: false do
        text    :body
        text    :status
        integer :checklist_id
      end

      after_commit   :resque_solr_update, :if => :persisted?
      before_destroy :resque_solr_remove

    elsif Rails.env.development?
      
      searchable do
        text    :body
        text    :status
        integer :checklist_id
      end
    
    end

  	acts_as_api

    def category_name
      category.name if category
    end

    def types
      ["S&C","Doc","Com"]
    end

    def phase_name
      category.phase.name if category && category.phase
    end

    def log_activity
        if status == "Completed"
            self.update_attribute :completed_date, Time.now if completed_date.nil?

            if completed_by_user
                activities.create!(
                    :body => "#{completed_by_user.full_name} just marked the following checklist item complete:\"#{body[0..15]}\"",
                    :user_id => completed_by_user_id,
                    :project_id => checklist.project.id,
                    :activity_type => self.class.name
                )
            else
                activities.create!(
                    :body => "The checklist item \"#{body[0..15]}\" was marked complete for #{checklist.project.name}",
                    :project_id => checklist.project.id,
                    :activity_type => self.class.name
                )
            end

            category.update_attribute :completed_date, Time.now if category.completed_count == category.item_count    
        else
            self.update_attributes :completed_date => nil, :completed_by_user_id => nil
        end
    end

    def project_id
        if checklist
            checklist.project.id
        else
            category.phase.checklist.project.id
        end
    end

    def has_critical_date?
        critical_date.present?
    end

    def has_completed_date?
        critical_date.present?
    end

  	api_accessible :projects do |t|
  		t.add :id
        t.add :body
  		t.add :critical_date, :if => :has_critical_date?
  		t.add :completed_date, :if => :has_completed_date?
        t.add :status
        t.add :item_type
        t.add :photos_count
        t.add :comments_count
        t.add :activities
        t.add :reminders
  	end

    api_accessible :checklist, :extend => :projects do |t|

    end

    api_accessible :details, :extend => :projects do |t|

    end

    api_accessible :dashboard, :extend => :projects do |t|
      
    end

    api_accessible :detail, :extend => :projects do |t|
        t.add :photos
        t.add :comments
        t.add :phase_name
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