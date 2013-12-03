class Checklist < ActiveRecord::Base
	attr_accessible :name, :type, :body, :user_id, :project_id, :milestone, :completed_date, :categories_attributes
  	belongs_to :project
  	has_many :categories
  	accepts_nested_attributes_for :categories

  	def self.to_csv(option = {})
  		CSV.generate(options) do |csv|
  			csv << column_names
  			all.each do |checklist|
  				csv << checklist.attributes.values_at(*column_names)
  			end
  		end
  	end

  	def self.import(file)
  		spreadsheet = open_spreadsheet(file)
  		header = spreadsheet.row(1)
  		(2..spreadsheet.last_row).each do |i|
  			row = Hash[header, spreadsheet.row(i)].transpose
  		end
  		CSV.foreach(file.path, headers: true) do |row|
  			Checklist.create row.to_hash
  		end
  	end

  	def open_spreadsheet(file)
  		case File.extname(file.original_filename)
  		when ".csv" then Csv.new(file.path, nil, :ignore)
  		when ".xls" then Excel.new(file.path, nil, :ignore)
  		when ".xlsx" then Excekx.new(file.path, nil, :ignore)
  		else raise "Unknown file type: #{file.original_filename}"
  		end

  	end
end
