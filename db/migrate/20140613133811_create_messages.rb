class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
    	t.belongs_to :user
    	t.belongs_to :target_project
    	t.belongs_to :company
    	t.text :body
      	t.timestamps
    end

    add_column :comments, :message_id, :integer
  end
end
