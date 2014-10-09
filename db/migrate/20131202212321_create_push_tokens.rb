class CreatePushTokens < ActiveRecord::Migration
  def change
    create_table :push_tokens do |t|
    	t.belongs_to :user
    	t.text :token
    	t.integer :device_type
      	t.timestamps
    end
  end
end
