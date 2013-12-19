class AddCoreAttrForProject < ActiveRecord::Migration
  def change
  	add_column :projects, :core, :boolean, :default => false
  	add_column :punchlist_items, :completed_by_user_id, :integer
  	add_column :companies, :image_file_name, :string
    add_column :companies, :image_content_type, :string
    add_column :companies, :image_file_size, :integer
    add_column :companies, :image_updated_at, :datetime
  end
end
