class ChangePunchlistToWorklist < ActiveRecord::Migration
  def change
  	rename_table :punchlists, :worklists
  	rename_table :punchlist_items, :worklist_items
  	rename_column :worklist_items, :punchlist_id, :worklist_id
  	rename_column :comments, :punchlist_item_id, :worklist_item_id
  	rename_column :notifications, :punchlist_item_id, :worklist_item_id
  	rename_column :subs, :punchlist_item_id, :worklist_item_id
  	rename_column :photos, :punchlist_item_id, :worklist_item_id
  	remove_index :worklist_items, name: "punchlist_items_assignee_id_ix"
  end
end
