class AddCountToReportUsers < ActiveRecord::Migration
  def change
  	add_column :report_users, :count, :integer, :default => 0
  	add_column :report_subs, :count, :integer, :default => 0
  end
end
