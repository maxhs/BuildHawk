class RemovePhotoDefaults < ActiveRecord::Migration
  def change
  	change_column_default(:photos, :folder, nil)
  	change_column_default(:photos, :name, nil)
  end
end
