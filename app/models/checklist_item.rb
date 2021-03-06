class ChecklistItem < ActiveRecord::Base
	attr_accessible :body, :item_type, :completed_by_user_id, :category_id, :critical_date, 
                    :completed_date,:photos, :photos_attributes, :checklist_id, :order_index, :photos_count, 
                    :comments_count, :state, :user_id#, :reminders_attributes
  	
  	belongs_to :user ## this could be the person who created the checklist item, if it was not a default item
    belongs_to :category
    belongs_to :checklist
    belongs_to :completed_by_user, :class_name => "User"
  	has_many :photos
  	has_many :comments, dependent: :destroy
    has_many :notifications, dependent: :destroy
    has_many :reminders, dependent: :destroy
    has_many :activities, dependent: :destroy
    acts_as_list scope: :category, column: :order_index
    default_scope { order('order_index') }

    accepts_nested_attributes_for :photos, :reject_if => lambda { |c| c[:image].blank? }
    accepts_nested_attributes_for :reminders

    if Rails.env.production?
        # websolr
        searchable auto_index: false, auto_remove: false do
            text        :body
            integer     :state
            integer :checklist_id
        end

        after_commit   :resque_solr_update, :if => :persisted?
        before_destroy :resque_solr_remove

    elsif Rails.env.development?
        searchable do
            text    :body
            integer    :state
            integer :checklist_id
        end
    end

  	acts_as_api

    def types
        ["S&C","Doc","Com"]
    end

    def abbreviated_body
        if body.length > 15
           "#{body[0..15]}..."
        else
            body
        end        
    end

    def log_activity(current_user)
        return unless checklist.project
        if state == 1
            category.update_column :completed_date, DateTime.now if category.completed_count == category.item_count 
            attribution = current_user ? "#{current_user.full_name} marked this item complete." : "This item was marked complete."
            user_id_field = current_user ? current_user.id : nil
            activities.create(
                :body => attribution,
                :user_id => user_id_field,
                :project_id => checklist.project.id,
                :activity_type => self.class.name
            )        
        else
            if state
                if state == 1
                    verbal_state = "completed"
                elsif state == 0
                    verbal_state = "in progress"
                elsif state == -1
                    verbal_state = "not applicable"
                else 
                    verbal_state = ""
                end
            else
                verbal_state = ""
            end
            attribution = current_user ? "#{current_user.full_name} updated the status for this item to \"#{verbal_state}\"." : "The status for this item was updated to \"#{verbal_state}\"."
            user_id_field = current_user ? current_user.id : nil
            activities.create!(
                :body => attribution,
                :project_id => checklist.project.id,
                :user_id => user_id_field,
                :activity_type => self.class.name
            )
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

    def status
        if state == 1
            "Completed"
        elsif state == 0
            "In-Progress"
        elsif state == -1
            "Not Applicable"
        end
    end

    def critical_date_epoch_time
        critical_date.to_i
    end
    def completed_date_epoch_time
        critical_date.to_i
    end

    api_accessible :dashboard do |t|
        t.add :id
        t.add :body
        t.add :critical_date, :if => :has_critical_date?
        t.add :critical_date_epoch_time, :if => :has_critical_date?
        t.add :completed_date, :if => :has_completed_date?
        t.add :completed_date_epoch_time, :if => :has_completed_date?
        t.add :item_type
        t.add :photos_count
        t.add :comments_count
        t.add :checklist_id
        t.add :project_id
        t.add :state
        ## slated for deletion
        t.add :status
    end

  	api_accessible :projects, :extend => :dashboard do |t|
  		
  	end

    api_accessible :visible_projects, :extend => :projects do |t|
        
    end

    api_accessible :notifications, :extend => :dashboard do |t|
    
    end

    api_accessible :reminders, :extend => :dashboard do |t|
        
    end

    api_accessible :v3_reports, :extend => :dashboard do |t|
        
    end

    api_accessible :reports, :extend => :dashboard do |t|
        
    end

    api_accessible :checklists, :extend => :dashboard do |t|
       
    end

    api_accessible :v3_checklists do |t|
        t.add :id
        t.add :state
        t.add :body
        t.add :item_type
        t.add :photos_count
        t.add :comments_count
        t.add :checklist_id
    end

    api_accessible :categories, :extend => :v3_checklists do |t|
        # t.add :critical_date, :if => :has_critical_date?
        # t.add :critical_date_epoch_time, :if => :has_critical_date?
        # t.add :completed_date, :if => :has_completed_date?
        # t.add :completed_date_epoch_time, :if => :has_completed_date?
    end

    api_accessible :details, :extend => :dashboard do |t|
        t.add :photos
        t.add :comments
        t.add :reminders
        t.add :activities
    end

    api_accessible :checklist_item, :extend => :details do |t|
        t.add :activities
    end

    protected
 
    def resque_solr_update
        Resque.enqueue(SolrUpdate, self.class.to_s, id)
    end

    def resque_solr_remove
        Resque.enqueue(SolrRemove, self.class.to_s, id)
    end

end