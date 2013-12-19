class AddPhaseToChecklistItem < ActiveRecord::Migration
  def change
  	add_column :checklist_items, :phase, :string
  end
end
