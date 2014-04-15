class AddDescriptionToChecklistModel < ActiveRecord::Migration
  def change
  	add_column :checklists, :description, :text
  end
end
