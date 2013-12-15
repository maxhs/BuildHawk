class AddCommentAttributes < ActiveRecord::Migration
  def change
  	add_column :comments, :checklist_item_id, :integer
  	add_column :comments, :punchlist_item_id, :integer

  	add_index :comments, :user_id, :name => 'comments_user_id_ix'
  	add_index :comments, :report_id, :name => 'comments_report_id_ix'
  	add_index :comments, :checklist_item_id, :name => 'comments_checklist_item_id_ix'
  	add_index :comments, :punchlist_item_id, :name => 'comments_punchlist_item_id_ix'
  	add_index :subcategories, :category_id, :name => 'subcategories_category_id_ix'
  	add_index :categories, :checklist_id, :name => 'categories_checklist_id_ix'
  	add_index :checklists, :project_id, :name => 'checklists_project_id_ix'
  	add_index :checklists, :company_id, :name => 'checklists_company_id_ix'
  	add_index :projects, :company_id, :name => 'projects_company_id_ix'
  	add_index :users, :company_id, :name => 'users_company_id_ix'
  	add_index :addresses, :user_id, :name => 'addresses_user_id_ix'
  	add_index :addresses, :company_id, :name => 'addresses_company_id_ix'
  	add_index :addresses, :project_id, :name => 'addresses_project_id_ix'
  	add_index :photos, :report_id, :name => 'photos_report_id_ix'
  	add_index :photos, :checklist_item_id, :name => 'photos_checklist_item_id_ix'
  	add_index :photos, :punchlist_item_id, :name => 'photos_punchlist_item_id_ix'
  	add_index :photos, :user_id, :name => 'photos_user_id_ix'
  	add_index :apn_registrations, :user_id, :name => 'apn_registrations_user_id_ix'
  	add_index :project_users, :project_id, :name => 'project_users_project_id_ix'
  	add_index :project_users, :user_id, :name => 'project_users_user_id_ix'
  	add_index :reports, :author_id, :name => 'reports_author_id_ix'
  	add_index :reports, :project_id, :name => 'reports_project_id_ix'
  	add_index :punchlist_items, :assignee_id, :name => 'punchlist_items_assignee_id_ix'
  end
end
