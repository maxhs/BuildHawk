class AddMorePhotoAttributes < ActiveRecord::Migration
  def change
  	add_column :photos, :name, :string, :default => ""
  	add_column :subcategories, :status, :string
  	add_column :categories, :status, :string
  end
end
