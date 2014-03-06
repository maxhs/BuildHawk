class CreateProjectSubs < ActiveRecord::Migration
  def change
    create_table :project_subs do |t|
    	t.belongs_to :project
    	t.belongs_to :sub
      	t.timestamps
    end
  end
end
