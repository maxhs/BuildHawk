class AddFolderToDocuments < ActiveRecord::Migration
  def change
  	add_column :photos, :folder, :string
  end
end
