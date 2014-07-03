class CreateConnectUsers < ActiveRecord::Migration
    def change
        create_table :connect_users do |t|
        	t.string :email
        	t.string :phone
        	t.string :first_name
        	t.string :last_name
        	t.belongs_to :worklist_item
        	t.belongs_to :checklist_item
        	t.belongs_to :report
          	t.timestamps
        end

        rename_column :reports, :created_date, :date_string
        rename_column :project_subs, :company_sub_id, :company_id
        add_column :reminders, :worklist_item_id, :integer
        add_column :checklist_items, :state, :integer
        add_column :categories, :state, :integer
        add_column :phases, :state, :integer
        remove_column :checklist_items, :status, :string
        remove_column :categories, :status, :string
        remove_column :phases, :status, :string
    end
end
