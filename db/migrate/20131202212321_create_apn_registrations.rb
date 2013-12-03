class CreateApnRegistrations < ActiveRecord::Migration
  def change
    create_table :apn_registrations do |t|
    	t.belongs_to :user
    	t.string :token
      	t.timestamps
    end
  end
end
