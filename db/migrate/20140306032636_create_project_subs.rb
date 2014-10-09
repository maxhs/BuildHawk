class CreateProjectSubs < ActiveRecord::Migration
  def change
    create_table :project_subs do |t|
    	t.references :project
    	t.references :company
      	t.timestamps
    end
  end
end
