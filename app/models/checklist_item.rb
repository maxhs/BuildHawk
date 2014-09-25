class ChecklistItem < ActiveRecord::Base
	attr_accessible :body, :item_type, :completed_by_user_id, :category_id, :critical_date, 
                    :completed_date,:photos, :photos_attributes, :checklist_id, :order_index, :photos_count, 
                    :comments_count, :reminder_date, :state, :user_id
  	
  	belongs_to :user ## this could be the person who created the checklist item, if it was not a default item
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

    accepts_nested_attributes_for :photos, :reject_if => lambda { |c| c[:image].blank? }

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

    def category_name
        category.name if category
    end

    def types
        ["S&C","Doc","Com"]
    end

    def phase_name
        category.phase.name if category && category.phase
    end

    def abbreviated_body
        if body.length > 15
           "#{body[0..15]}..."
        else
            body
        end        
    end

    def log_activity(current_user)
        puts "should be logging a checklist item activity"
        puts "user? #{current_user.full_name}" if current_user
        if state == 1 && completed_date.nil?
            #category.update_attribute :completed_date, Time.now if category.completed_count == category.item_count 
            
            if current_user
                activities.create(
                    :body => "#{current_user.full_name} marked this item complete.",
                    :user_id => current_user.id,
                    :project_id => checklist.project.id,
                    :activity_type => self.class.name
                )
            else 
                activities.create(
                    :body => "This item was marked complete.",
                    :project_id => checklist.project.id,
                    :activity_type => self.class.name
                )
            end            
               
        elsif !completed_date.nil?
            puts "no completed date"
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

                if current_user
                    puts "current user activity"
                    activities.create(
                        :body => "#{current_user.full_name} updated the status for this item\" to #{verbal_state}\".",
                        :project_id => checklist.project.id,
                        :user_id => current_user.id,
                        :activity_type => self.class.name
                    )
                else 
                    puts "activity for someone else"
                    activities.create(
                        :body => "The status for this item was updated\" to #{verbal_state}\".",
                        :project_id => checklist.project.id,
                        :activity_type => self.class.name
                    )
                end
            end
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

    def status
        if state == 1
            "Completed"
        elsif state == 0
            "In-Progress"
        elsif state == -1
            "Not Applicable"
        end
    end

    # def ugh_parse
    #     url = Rails.root.join("public","ugh.txt")
    #     text = File.open(url).read.split("#<")
    #     id = " id: "
    #     state = " state: "
    #     text.each do |t|
    #         actual_id = t[/#{id}(.*?),/m,1]
    #         actual_state = t[/#{state}(.*?)>/m,1]
    #         if actual_id && actual_state
    #             item = ChecklistItem.find actual_id
    #             item.update_attribute :state, actual_state
    #             puts "id: #{actual_id} and state #{actual_state}"
    #         end
    #     end
    # end

    api_accessible :dashboard do |t|
        t.add :id
        t.add :body
        t.add :critical_date, :if => :has_critical_date?
        t.add :completed_date, :if => :has_completed_date?
        t.add :state
        t.add :item_type
        t.add :photos_count
        t.add :comments_count
        t.add :checklist_id
        t.add :project_id
        ## slated for deletion
        t.add :status
    end

  	api_accessible :projects, :extend => :dashboard do |t|
  		
  	end

    api_accessible :checklists, :extend => :dashboard do |t|
       
    end

    api_accessible :notifications, :extend => :dashboard do |t|
    
    end

    api_accessible :reminders, :extend => :dashboard do |t|
        t.add :id
        t.add :body
        t.add :critical_date, :if => :has_critical_date?
        t.add :completed_date, :if => :has_completed_date?
        t.add :status
        t.add :state
        t.add :item_type
        t.add :photos_count
        t.add :checklist_id
    end

    api_accessible :details, :extend => :dashboard do |t|
        t.add :photos
        t.add :comments
        t.add :phase_name
        t.add :reminders
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