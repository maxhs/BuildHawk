class AddReportFieldAttributes < ActiveRecord::Migration
  def change
  	add_column :report_fields, :description, :text
  end
end
