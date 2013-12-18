class AddCommentAttributes < ActiveRecord::Migration
  def change
  	add_index :comments, [:user_id, :report_id, :checklist_item_id,:punchlist_item_id], :name => 'comments_ix'
  	add_index :subcategories, :category_id, :name => 'subcategories_category_id_ix'
  	add_index :categories, :checklist_id, :name => 'categories_checklist_id_ix'
  	add_index :checklists, [:project_id, :company_id], :name => 'checklists_ix'
  	add_index :projects, :company_id, :name => 'projects_company_id_ix'
  	add_index :users, :company_id, :name => 'users_company_id_ix'
  	add_index :addresses, [:user_id, :company_id, :project_id], :name => 'addresses_ix'
  	add_index :photos, [:report_id, :checklist_item_id, :punchlist_item_id, :user_id], :name => 'photos_ix'
  	add_index :apn_registrations, :user_id, :name => 'apn_registrations_user_id_ix'
  	add_index :project_users, [:project_id, :user_id], :name => 'project_users_ix'
  	add_index :reports, [:author_id, :project_id], :name => 'reports_ix'
  	add_index :punchlist_items, :assignee_id, :name => 'punchlist_items_assignee_id_ix'

    remove_index :checklist_items, :name => 'checklist_item_category_id_ix'
    remove_index :checklist_items, :name => 'checklist_item_subcategory_id_ix'
    remove_index :checklist_items, :name => 'checklist_item_checklist_id_ix'

    add_index :checklist_items, [:subcategory_id, :checklist_id], :name => "checklist_items_ix"

    remove_column :checklist_items, :complete, :boolean
  end
end
