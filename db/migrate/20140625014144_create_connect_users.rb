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
  end
end
