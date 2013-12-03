class CreateProjectUsers < ActiveRecord::Migration
  def change
    create_table :project_users do |t|
    	t.belongs_to :user
    	t.belongs_to :project
      	t.timestamps
    end
  end
end
