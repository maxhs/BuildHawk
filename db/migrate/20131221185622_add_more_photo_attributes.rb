class AddMorePhotoAttributes < ActiveRecord::Migration
  def change
  	add_column :photos, :name, :string, :default => ""
  end
end
