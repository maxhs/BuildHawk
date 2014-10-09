class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
    	t.references :user
    	t.references :report
    	t.references :checklist_item
    	t.text :body
      	t.timestamps
    end
  end
end
