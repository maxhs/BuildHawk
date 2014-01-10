class AddSubAssigneeToPunchlistItem < ActiveRecord::Migration
  def change
  	remove_column :punchlist_items, :assignee_name, :string
  	add_column :punchlist_items, :sub_assignee_id, :integer
  end
end
