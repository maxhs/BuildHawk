class CreatePromoCodes < ActiveRecord::Migration
  def change
    create_table :promo_codes do |t|
    	t.belongs_to :user
    	t.string :code
    	t.decimal :percentage, precision: 5
    	t.integer :days
      	t.timestamps
    end
  end
end
