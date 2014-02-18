class Checklist < ActiveRecord::Base
	require 'roo'
    include ActionView::Helpers::NumberHelper
    
    attr_accessible :name, :checklist_type, :body, :user_id, :project_id, :milestone_date, :completed_date, :categories_attributes, 
    				        :categories, :company, :company_id
  	belongs_to :project
  	belongs_to :company
  	
    has_many :checklist_items, :dependent => :destroy
  	has_many :categories, :dependent => :destroy
  	accepts_nested_attributes_for :categories, :allow_destroy => true

    amoeba do
        clone :categories
        set :core => false
    end

    after_create :assign_items

  	def completed_count
        if checklist_items.count
            items = checklist_items
        else
  		    items = categories.map(&:subcategories).flatten.map(&:checklist_items).flatten
        end
        return items.select{|i| i.status == "Completed"}.count
  	end

  	def item_count
        if checklist_items.count
            checklist_items.count
        else
  		    categories.map(&:subcategories).flatten.map(&:checklist_items).flatten.count
        end
  	end

  	def items
        if checklist_items.count > 0
            checklist_items
        else 
  		    checklist_items << categories.sort_by{|c|c.name.to_i}.map(&:subcategories).flatten.map(&:checklist_items).flatten
            return checklist_items
        end
  	end

    def upcoming_items
        items.select{|i| i.critical_date}.sort_by(&:critical_date).last(5)
    end

    def recently_completed
        items.select{|i| i.status == "Completed"}.sort_by(&:completed_date).reverse.first(5)
    end

    def progress_percentage
      number_to_percentage(completed_count.to_f/item_count.to_f*100,:precision=>1)
    end

    def progress
        completed_count.to_f/item_count.to_f*100
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
        t.add :categories
        t.add :name
    end

end
