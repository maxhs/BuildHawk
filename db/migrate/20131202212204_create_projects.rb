class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
    	t.boolean :active, :default => true
    	t.belongs_to :company
    	t.string :name
      	t.timestamps
    end
  end
end
