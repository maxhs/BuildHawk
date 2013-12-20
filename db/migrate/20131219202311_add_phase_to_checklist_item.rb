class AddPhaseToChecklistItem < ActiveRecord::Migration
  def change
  	add_column :photos, :phase, :string
  	add_column :users, :active, :boolean, :default => true
  	add_column :punchlist_items, :assignee_name, :string
  end
end
