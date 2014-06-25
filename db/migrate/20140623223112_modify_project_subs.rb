class ModifyProjectSubs < ActiveRecord::Migration
  def change
  	rename_column :project_subs, :sub_id, :company_sub_id
  	rename_table :edits, :activities
  	add_column :activities, :activity_type, :string
  	add_column :worklist_items, :assigned_name, :string
  	add_column :worklist_items, :assigned_email, :string
  	add_column :worklist_items, :assigned_phone, :string
  	add_column :activities, :comment_id, :integer
  end
end
