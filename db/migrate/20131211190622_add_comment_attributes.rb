class AddCommentAttributes < ActiveRecord::Migration
  def change
  	add_column :comments, :checklist_item_id, :integer
  	add_column :comments, :punchlist_item_id, :integer
  end
end
