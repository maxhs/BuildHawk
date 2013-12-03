class CreateChecklistItems < ActiveRecord::Migration
  def change
    create_table :checklist_items do |t|
    	t.boolean :complete, :default => false
    	t.string :status
    	t.text :body
    	t.belongs_to :checklist
      	t.timestamps
    end
  end
end
