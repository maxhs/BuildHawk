class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
    	t.references :report
    	t.references :user
    	t.references :checklist_item
    	t.references :task
    	t.references :project
      t.references :comment
      t.references :message
      t.references :photo
      t.text :body
      t.string :activity_type
    	t.boolean :hidden, default: false
      t.timestamps
    end
  end
end
