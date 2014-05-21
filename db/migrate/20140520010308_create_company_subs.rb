class CreateCompanySubs < ActiveRecord::Migration
  def change
    create_table :company_subs do |t|
    	t.belongs_to :company
    	t.belongs_to :subcontractor, class_name: "Company"
      	t.timestamps
    end
  end
end
