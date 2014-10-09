class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
    	t.text :body
    	t.references :tasklist
    	t.references :assignee, :class_name => "User"
    	t.string :location
    	t.integer :order_index
      t.string :assignee_name
      t.timestamps
    end
    add_column :comments, :task_id, :integer
  end
end
