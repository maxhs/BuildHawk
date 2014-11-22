class AddAttributesToMessages < ActiveRecord::Migration
  	def change
  		add_column :messages, :sent, :boolean, default: false
  		add_column :messages, :archived, :boolean
  		add_column :messages, :read, :boolean
  	end
end
