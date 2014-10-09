class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
    	t.boolean :read, :default => false
    	t.boolean :sent, :default => false
    	t.references :user
    	t.references :report
    	t.references :task
        t.references :project
        t.references :comment
    	t.references :checklist_item
    	t.text :message
    	t.string :notification_type
      t.timestamps
    end
    add_column :checklist_items, :photos_count, :integer
    add_column :checklist_items, :comments_count, :integer
    add_column :tasks, :photos_count, :integer
    add_column :tasks, :comments_count, :integer
  end
end
