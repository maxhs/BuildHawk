class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
    	t.string :name
    	t.belongs_to :project
      	t.timestamps
    end

    add_column :photos, :folder_id, :integer
    remove_column :photos, :folder, :string
  end
end
