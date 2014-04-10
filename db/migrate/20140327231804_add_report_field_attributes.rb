class AddReportFieldAttributes < ActiveRecord::Migration
  def change
  	add_column :report_fields, :description, :text
  	add_column :photos, :description, :text
    add_column :project_users, :archived, :boolean, default: false
    add_column :project_users, :core, :boolean, default: false
    add_column :project_users, :project_group_id, :integer
    add_column :projects, :archived, :boolean, default: false
  end
end
