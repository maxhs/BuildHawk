class CreateTasklists < ActiveRecord::Migration
  def change
    create_table :tasklists do |t|
    	t.references :project
      	t.timestamps
    end
  end
end
