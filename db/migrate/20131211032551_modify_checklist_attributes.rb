class ModifyChecklistAttributes < ActiveRecord::Migration
  def change
  	add_column :checklists, :core, :boolean, :default => false
  end
end
