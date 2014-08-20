class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
    	t.string :last4
    	t.string :exp_month
      t.string :exp_year
    	t.belongs_to :company
    	t.text :customer_token
    	t.boolean :active, default: false
      	t.timestamps
    end
    remove_column :companies, :customer_token, :string
  end
end
