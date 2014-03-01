class CreatePromoCodes < ActiveRecord::Migration
  def change
    create_table :promo_codes do |t|
    	t.belongs_to :user
    	t.string :code
    	t.decimal :percentage, precision: 5, scale: 2
    	t.integer :days
    	t.integer :use_count, default: 0
      	t.timestamps
    end
  end
end
