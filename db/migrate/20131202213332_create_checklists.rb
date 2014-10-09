class CreateChecklists < ActiveRecord::Migration
  def change
    create_table :checklists do |t|
      t.references :project
      t.references :company
      t.string :name
      t.datetime :completed_date
      t.datetime :milestone_date
      t.integer :checklist_items_count
      t.boolean :core, :default => false
      t.text :description
      t.timestamps
    end
  end
end
