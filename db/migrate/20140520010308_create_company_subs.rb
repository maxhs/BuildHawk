class CreateCompanySubs < ActiveRecord::Migration
  def change
    create_table :company_subs do |t|
    	t.belongs_to :company
      	t.timestamps
    end
  end
end
