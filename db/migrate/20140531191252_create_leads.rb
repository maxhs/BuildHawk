class CreateLeads < ActiveRecord::Migration
  def change
    create_table :leads do |t|
    	t.string :name
    	t.string :company_name
    	t.string :email
    	t.string :phone_number
      	t.timestamps
    end
  end
end
