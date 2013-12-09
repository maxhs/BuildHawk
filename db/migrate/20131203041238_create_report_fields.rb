class CreateReportFields < ActiveRecord::Migration
  def change
    create_table :report_fields do |t|
    	t.belongs_to :report
        t.timestamps
    end

  end
end
