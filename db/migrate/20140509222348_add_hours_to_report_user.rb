class AddHoursToReportUser < ActiveRecord::Migration
  def change
  	add_column :report_users, :hours, :float
  	remove_column :checklist_items, :subcategory_id
  end
end
