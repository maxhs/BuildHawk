class Checklist < ActiveRecord::Base
	require 'roo'
    attr_accessible :name, :checklist_type, :body, :user_id, :project_id, :milestone, :completed_date, :categories_attributes, :categories
  	belongs_to :project
  	belongs_to :company
  	
  	has_many :categories
  	accepts_nested_attributes_for :categories

  	def self.import(file)
	  spreadsheet = open_spreadsheet(file)
	  header = spreadsheet.row(2)
	  category_title = spreadsheet.row(2)[0]
	  subcategory_title = spreadsheet.row(2)[1]
	  type_title = spreadsheet.row(2)[2]
	  item_title = spreadsheet.row(2)[3]

	  @new_core = CoreChecklist.create
	  (3..spreadsheet.last_row).each do |i|
	    row = Hash[[header, spreadsheet.row(i)].transpose]
	    category = @new_core.categories.find_or_create_by(name: row[category_title])
	    subcategory = category.subcategories.find_or_create_by(name: row[subcategory_title])
	    item = subcategory.checklist_items.create :item_type => row[type_title], :body => row[item_title]
	  end
	end

	def self.open_spreadsheet(file)
	  case File.extname(file.original_filename)
	  when ".csv" then Csv.new(file.path, nil, :ignore)
	  when ".xls" then Excel.new(file.path, nil, :ignore)
	  when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
	  else raise "Unknown file type: #{file.original_filename}"
	  end
	end
end
