class CreateSubs < ActiveRecord::Migration
  def change
    create_table :subs do |t|
    	t.string :name
    	t.belongs_to :company
    	t.string :email
    	t.string :phone_number
      	t.timestamps
    end
  end
end
