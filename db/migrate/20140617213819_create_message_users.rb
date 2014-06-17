class CreateMessageUsers < ActiveRecord::Migration
  def change
    create_table :message_users do |t|
    	t.belongs_to :message
    	t.belongs_to :user
    	t.boolean :sent, default: false
    	t.boolean :read, default: false
      	t.timestamps
    end
  end
end
