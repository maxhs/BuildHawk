class CreateReportUsers < ActiveRecord::Migration
  def change
    create_table :report_users do |t|
    	t.belongs_to :report
    	t.belongs_to :user
      t.timestamps
    end
  end
end
