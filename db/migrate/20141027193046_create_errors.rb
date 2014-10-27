class CreateErrors < ActiveRecord::Migration
  def change
    create_table :errors do |t|
    	t.references :user
    	t.references :report
    	t.references :task
    	t.references :checklist_item
    	t.references :photo
    	t.references :message
    	t.text :body
    	t.boolean :fixed, default: false
    	t.string :status_code
      	t.timestamps
    end
  end
end
