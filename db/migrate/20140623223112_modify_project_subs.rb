class ModifyProjectSubs < ActiveRecord::Migration
  def change
  	rename_column :project_subs, :sub_id, :company_sub_id
  	rename_table :edits, :activities
  end
end
