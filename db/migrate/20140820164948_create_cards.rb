class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
    	t.string :public_digits
    	t.string :expiration
    	t.belongs_to :company
    	t.text :customer_token
      	t.timestamps
    end
    remove_column :companies, :customer_token, :string
  end
end
