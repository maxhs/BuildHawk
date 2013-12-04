class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
 	  t.integer :index
 	  t.belongs_to :checklist
 	  t.belongs_to :core_checklist
 	  t.datetime :completed_date
      t.datetime :milestone_date
      t.string :name
      t.timestamps
    end
  end
end
