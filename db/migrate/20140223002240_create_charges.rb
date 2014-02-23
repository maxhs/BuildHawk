class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
    	t.belongs_to :company
    	t.boolean :paid, default: false
    	t.text :description, default: ""
    	t.string :promo_code, default: ""
      	t.timestamps
    end
  end
end
