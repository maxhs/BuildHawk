class CreatePunchlists < ActiveRecord::Migration
  def change
    create_table :punchlists do |t|
    	t.boolean :worklist, :default => false
    	t.belongs_to :project

      	t.timestamps
    end
  end
end
