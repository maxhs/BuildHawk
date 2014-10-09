class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
    	t.belongs_to :user
    	t.belongs_to :checklist_item
      t.references :task
    	t.belongs_to :project
    	t.datetime :reminder_datetime
    	t.boolean :email
    	t.boolean :text
    	t.boolean :push
      t.boolean :active, default: true
      	t.timestamps
    end
  end
end
