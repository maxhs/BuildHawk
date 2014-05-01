class Checklist < ActiveRecord::Base
	require 'roo'
    require 'deep_cloneable'
    include ActionView::Helpers::NumberHelper
    
    attr_accessible :name, :description, :body, :user_id, :project_id, :milestone_date, :completed_date, :categories_attributes, 
    				:categories, :company_id, :core
  	belongs_to :project
  	belongs_to :company
  	
    has_many :checklist_items, :dependent => :destroy
  	has_many :categories, :dependent => :destroy
  	accepts_nested_attributes_for :categories, :allow_destroy => true

    after_create :assign_items
    after_commit :uber_fifo

    def uber_fifo
        if core && company_id.nil?
            lists = Checklist.where(:name => name, :core => true, :project_id => nil, :company_id => nil)
            # while lists.count < 5
            #     puts "should create more uber checklist templates"
            #     if Rails.env.production?
            #         puts "should be creating another uber checklist in production"
            #         #Resque.enqueue(DuplicateChecklist,self,nil)
            #     elsif Rails.env.development?
            #         @new_list = self.dup :include => {:categories => {:subcategories => :checklist_items}}
            #         puts "should be creating another uber checklist in development: #{@new_list.name}"
            #         @new_list.save
            #     end
            # end
        end
    end    

    def core_fifo
        if core && company_id
            puts "in core fifo. company id: #{company_id}"
            lists = Checklist.where(:name => name, :core => true, :project_id => nil, :company_id => company_id)
            list_count = lists.count
            # while list_count < 5
            #     if Rails.env.production?
            #         puts "should be creating another checklist in production"
            #         #Resque.enqueue(DuplicateChecklist,list,company_id)

            #     elsif Rails.env.development?
            #         new_list = self.dup(:include => {:categories => {:subcategories => :checklist_items}}, :except => {:categories => {:subcategories => {:checklist_items => :status}}})
            #         new_list.company_id = company_id
            #         new_list.save
            #         puts "created a new list in development: #{new_list.id} & company: #{new_list.company_id}"
            #     end
            #     puts "lists count: #{lists.count}"
            #     list_count += 1
            # end
        end
    end

    def duplicate
        self.dup :include => [:company, {:categories => {:subcategories => :checklist_items}}], :except => {:categories => {:subcategories => {:checklist_items => :status}}}
    end

    def items
        if checklist_items.count > 0
            checklist_items
        else 
            checklist_items << categories.sort_by{|c|c.name.to_i}.map(&:subcategories).flatten.map(&:checklist_items).flatten
            return checklist_items
        end
    end

  	def completed_count
        if checklist_items.count
            items = checklist_items
        else
  		    items = categories.map(&:subcategories).flatten.map(&:checklist_items).flatten
        end
        return items.select{|i| i.status == "Completed"}.count
  	end

    def not_applicable_count
        items.select{|i| i.status == "Not Applicable"}.count
    end

  	def item_count
        if checklist_items && checklist_items.count > 0
            checklist_items.count
        else
  		    self.checklist_items = categories.map(&:subcategories).flatten.map(&:checklist_items).flatten
            self.save
            return self.checklist_items.count
        end
  	end

    def upcoming_items
        items.select{|i| i.critical_date if i.status != "Completed"}.sort_by(&:critical_date).last(5)
    end

    def recently_completed
        items.select{|i| i.status == "Completed"}.sort_by(&:completed_date).reverse.first(5)
    end

    def progress_percentage
        number_to_percentage((completed_count+not_applicable_count)/item_count.to_f*100,:precision=>1)
    end

    def progress
        (completed_count+not_applicable_count)/item_count.to_f*100
    end

    class << self
      	def import(file)
            spreadsheet = open_spreadsheet(file)
            header = spreadsheet.row(2)
            category_title = spreadsheet.row(2)[0]
            subcategory_title = spreadsheet.row(2)[1]
            type_title = spreadsheet.row(2)[2]
            item_title = spreadsheet.row(2)[3]

            @new_core = self.create :core => true
            item_index = 0
            (3..spreadsheet.last_row).each do |i|
                row = Hash[[header, spreadsheet.row(i)].transpose]
                category = @new_core.categories.where(:name => row[category_title]).first_or_create
                subcategory = category.subcategories.where(:name => row[subcategory_title]).first_or_create
                item = subcategory.checklist_items.create :item_type => row[type_title], :body => row[item_title], :item_index => item_index if row[type_title] || row[item_title]
                item_index += 1
    	    end
            @new_core.core = true
    	    @new_core.save
    	end

    	def open_spreadsheet(file)
            case File.extname(file.original_filename)
            when ".csv" then Csv.new(file.path, nil, :ignore)
            when ".xls" then Excel.new(file.path, nil, :ignore)
            when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
            else raise "Unknown file type: #{file.original_filename}"
            end
    	end
    end

    def assign_items
        checklist_items << categories.sort_by{|c|c.name.to_i}.map(&:subcategories).flatten.map(&:checklist_items).flatten 
        sub_index = 0
        categories.sort_by{|c|c.name.to_i}.each do |i|
            i.update_attribute :order_index, sub_index
            sub_index += 1
        end
    end

	acts_as_api

	api_accessible :user do |t|

	end

	api_accessible :projects do |t|
		t.add :name
        t.add :id
	end

    api_accessible :checklist do |t|
        t.add :id
        t.add :categories
        t.add :name
    end

end
