class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
    	t.belongs_to :user
    	t.belongs_to :target_project
    	t.text :body
      	t.timestamps
    end
  end
end
