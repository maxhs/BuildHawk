class AddFolderToDocuments < ActiveRecord::Migration
  def change
  	remove_column :photos, :folder, :string
  	#add_column :photos, :folder, :string, :default => ""
  	#change_column :photos, :folder, :string, null: false
  	#change_column :photos, :name, :string, :default => "", null: false
  end
end
