class CreateReportSubs < ActiveRecord::Migration
  def change
    create_table :report_subs do |t|
    	t.belongs_to :sub
    	t.belongs_to :report
      	t.timestamps
    end
  end
end
