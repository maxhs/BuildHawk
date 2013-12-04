class AddAttributes < ActiveRecord::Migration
  def change
  	add_column :projects, :checklist_id, :integer
  end
end
