class AddUserToChecklistItem < ActiveRecord::Migration
  def change
  	add_column :checklist_items, :user_id, :integer
  	add_column :report_subs, :hours, :float
  end
end
