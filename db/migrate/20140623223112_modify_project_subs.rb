class ModifyProjectSubs < ActiveRecord::Migration
  def change
  	rename_column :project_subs, :sub_id, :company_sub_id
  	rename_table :edits, :activities
  	add_column :activities, :activity_type, :string
  	add_column :activities, :comment_id, :integer
  	add_column :activities, :message_id, :integer
  end
end
