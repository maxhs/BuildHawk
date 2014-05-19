class CreateReportCompanies < ActiveRecord::Migration
  def change
    create_table :report_companies do |t|
    	t.belongs_to :report
    	t.belongs_to :company
    	t.integer :count
      	t.timestamps
    end
  end
end
