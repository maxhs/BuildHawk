class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
    	t.attachment :image
      	t.belongs_to :company
      	t.belongs_to :user
      	t.belongs_to :project
      	t.string :source
      	t.timestamps
    end
  end
end
