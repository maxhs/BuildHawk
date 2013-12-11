class ModifyChecklistAttributes < ActiveRecord::Migration
  def change
  	add_column :checklists, :core, :boolean, :default => false
  	add_column :users, :authentication_token, :string
  end
end
