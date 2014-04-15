class CreateSafetyTopics < ActiveRecord::Migration
  def change
    create_table :safety_topics do |t|
    	t.belongs_to :company
    	t.belongs_to :report
    	t.string :title
    	t.text :info
      t.boolean :core, default: false
      t.timestamps
    end
    add_column :notifications, :feed, :boolean, default: false
  end
end
