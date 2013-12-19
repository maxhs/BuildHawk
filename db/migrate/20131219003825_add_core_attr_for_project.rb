class AddCoreAttrForProject < ActiveRecord::Migration
  def change
  	add_column :projects, :core, :boolean, :default => false
  	add_column :punchlist_items, :completed_by_user_id, :integer
  end
end
