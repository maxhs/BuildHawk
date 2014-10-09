class AddCommentAttributes < ActiveRecord::Migration
  def change
  	add_index :comments, [:user_id, :report_id, :checklist_item_id,:task_id], :name => 'comments_idx'
  	add_index :phases, :checklist_id, :name => 'phases_checklist_id_idx'
  	add_index :categories, :phase_id, :name => 'categories_phase_id_idx'
  	add_index :checklists, [:project_id, :company_id], :name => 'checklists_idx'
  	add_index :projects, :company_id, :name => 'projects_company_id_idx'
  	add_index :users, :company_id, :name => 'users_company_id_idx'
  	add_index :addresses, [:user_id, :company_id, :project_id], :name => 'addresses_idx'
  	add_index :photos, [:report_id, :checklist_item_id, :task_id, :user_id], :name => 'photos_idx'
  	add_index :push_tokens, :user_id, :name => 'apn_registrations_user_id_idx'
  	add_index :project_users, [:project_id, :user_id], :name => 'project_users_idx'
  	add_index :reports, [:author_id, :project_id], :name => 'reports_idx'
  	add_index :tasks, :assignee_id, :name => 'tasks_assignee_id_idx'
    add_index :checklist_items, [:category_id, :checklist_id], :name => "checklist_items_idx"
  end
end
