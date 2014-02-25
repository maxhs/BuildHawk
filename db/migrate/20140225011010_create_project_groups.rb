class CreateProjectGroups < ActiveRecord::Migration
  def change
    create_table :project_groups do |t|
    	t.belongs_to :company
    	t.string :name, default:""
    	t.integer :projects_count
    	t.timestamps
    end

    add_column :companies, :valid_billing, :boolean, default: false
    add_column :projects, :project_group_id, :integer
  end
end
