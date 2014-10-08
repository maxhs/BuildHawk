class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
    	t.belongs_to :user
    	t.belongs_to :checklist_item
      t.references :punchlist_item
    	t.belongs_to :project
    	t.datetime :reminder_datetime
    	t.boolean :email
    	t.boolean :text
    	t.boolean :push
      	t.timestamps
    end
  end
end
