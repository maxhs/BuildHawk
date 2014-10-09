class CreateCards < ActiveRecord::Migration
    def change
        create_table :cards do |t|
        	t.string :last4
        	t.string :exp_month
            t.string :exp_year
        	t.belongs_to :company
        	t.text :card_id
            t.string :brand
            t.string :address_line1
            t.string :address_line2
            t.string :address_city
            t.string :address_state
            t.string :address_zip
            t.string :country
            t.string :name
        	t.boolean :active, default: false
          	t.timestamps
        end
    end
end
