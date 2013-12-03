class CreateSubcategories < ActiveRecord::Migration
  def change
    create_table :subcategories do |t|
      t.belongs_to :category
      t.integer :index
      t.datetime :completed_date
      t.datetime :milestone_date
      t.timestamps
    end
  end
end
