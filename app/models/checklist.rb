class Checklist < ActiveRecord::Base
	require 'roo'
    require 'deep_cloneable'
    include ActionView::Helpers::NumberHelper
    
    attr_accessible :name, :description, :body, :user_id, :project_id, :milestone_date, :completed_date, :phases_attributes, 
    				:phases, :company_id, :core, :flagged_for_removal
                    
  	belongs_to :project
  	belongs_to :company
  	
    has_many :checklist_items, :dependent => :destroy
  	has_many :phases, :dependent => :destroy
  	accepts_nested_attributes_for :phases, :allow_destroy => true

    def duplicate(company_id, project_id)
        if Rails.env.production?
            require "resque"
            Resque.enqueue(PopulateChecklist, company_id, project_id, id)
        else
            new_checklist = self.deep_clone :include => {phases: {categories: :checklist_items}}, except: {phases: {categories: {checklist_items: :state}}}
            new_checklist.company_id = company_id
            if project_id
                new_checklist.core = false
                new_checklist.project_id = project_id
            else
                new_checklist.core = true
            end
            new_checklist.save
        end
    end

    def items
        if checklist_items.count > 0
            checklist_items
        else 
            checklist_items << phases.sort_by{|c|c.name.to_i}.map(&:categories).flatten.map(&:checklist_items).flatten
            return checklist_items
        end
    end

  	def completed_count
        if checklist_items.count
            items = checklist_items
        else
  		    items = phases.map(&:categories).flatten.map(&:checklist_items).flatten
        end
        return items.select{|i| i.state == 1}.count
  	end

    def not_applicable_count
        items.select{|i| i.state == -1}.count
    end

  	def item_count
        if checklist_items && checklist_items.count > 0
            checklist_items.count
        else
  		    self.checklist_items = phases.map(&:categories).flatten.map(&:checklist_items).flatten
            self.save
            return self.checklist_items.count
        end
  	end

    def upcoming_items
        items.select{|i| i.critical_date if i.state != 1}.sort_by(&:critical_date).last(5)
    end

    def recently_completed
        items.select{|i| i.state if i.state == 1 && !i.completed_date.nil?}.sort_by(&:completed_date).reverse.first(5)
    end

    def progress_percentage
        number_to_percentage((completed_count+not_applicable_count)/item_count.to_f*100,:precision=>1)
    end

    def progress
        (completed_count+not_applicable_count)/item_count.to_f*100
    end

    def background_destroy
        if Rails.env.production?
            require "resque"
            Resque.enqueue(DestroyChecklist, id)
        else
            self.destroy
        end
    end

    class << self
      	def import(file)
            spreadsheet = open_spreadsheet(file)
            header = spreadsheet.row(2)
            phase_title = spreadsheet.row(2)[0].to_s
            category_title = spreadsheet.row(2)[1].to_s
            type_title = spreadsheet.row(2)[2].to_s
            item_title = spreadsheet.row(2)[3].to_s

            @new_core = self.create :core => true
            order_index = 0
            (0..spreadsheet.last_row).each do |i|
                row = Hash[[header, spreadsheet.row(i)].transpose]
                phase = @new_core.phases.where(:name => row[phase_title]).first_or_create
                category = phase.categories.where(:name => row[category_title]).first_or_create
                item = category.checklist_items.create :item_type => row[type_title], :body => row[item_title], :order_index => order_index if row[type_title] || row[item_title]
                order_index += 1
    	    end
            @new_core.core = true
    	    @new_core.save
    	end

    	def open_spreadsheet(file)
            case File.extname(file.original_filename)
            when ".csv" then CSV.new(file.path, nil, :ignore)
            when ".xls" then Excel.new(file.path, nil, :ignore)
            when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
            else raise "Unknown file type: #{file.original_filename}"
            end
    	end
    end

    def assign_items
        checklist_items << phases.sort_by{|c|c.name.to_i}.map(&:categories).flatten.map(&:checklist_items).flatten 
        sub_index = 0
        phases.sort_by{|c|c.name.to_i}.each do |i|
            i.update_attribute :order_index, sub_index
            sub_index += 1
        end
    end

    ## slated for deletion
    def categories
        phases
    end
    ##

	acts_as_api

	api_accessible :user do |t|

	end

	api_accessible :projects do |t|
		t.add :name
        t.add :id
	end

    api_accessible :checklists do |t|
        t.add :id
        t.add :phases
        t.add :name
        t.add :project_id
        ## slated for deletion
        #t.add :categories
        ##
    end

    api_accessible :v3_checklists do |t|
        t.add :id
        t.add :phases
        t.add :name
        t.add :project_id
    end

end
