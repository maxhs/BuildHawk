class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
    	t.attachment :image
      	t.references :company
      	t.references :user
      	t.references :project
        t.references :comment
        t.string :name, default: ""
        t.string :phase
      	t.string :source, default: "Documents"
      	t.timestamps
    end
  end
end
